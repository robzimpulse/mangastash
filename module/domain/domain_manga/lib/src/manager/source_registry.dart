// SourceRegistry (issue #115, spec §8): resolves the JavaScript sources the app
// uses by combining the scripts bundled as assets (`assets/sources/<id>.js`,
// ids in [shippedSourceIds]) with the user's rows in `source_script_tables`.
//
// Resolution per id: a DB row wins over the bundled asset ("last edit wins").
// Entries are ordered shipped ids first (in [shippedSourceIds] order) then the
// remaining entries sorted by name. A bundled asset that fails to load or parse
// is logged and skipped; it never makes `create` throw.
//
// It also exposes the sources as `SourceExternal`s (issue #115 Task 10):
// [SourceRegistry.values] is the built-in MangaDex source followed by one
// `ScriptSourceExternal` per entry, rebuilt before `entries` emits, so a
// listener of `entries` always reads fresh adapters.
//
// Usage:
//   final registry = await SourceRegistry.create(
//     dao: locator<SourceScriptDao>(),
//     runner: locator<RunSourceScriptUseCase>(),
//     loadAsset: rootBundle.loadString,
//   );
//   registry.entries            // ValueStream<List<SourceEntry>>
//   registry.values             // [MangaDex, ...one adapter per entry]
//   registry.fromName('Asura Scans') / registry.fromHost('asurascans.com')
//   registry.classify(code)     // NewSource | ReplacesSource, for the editor UI
//   await registry.save(code);  // throws SourceScriptFormatException or
//                               // SourceScriptRejected, before any write
//   await registry.reset(id);   // shipped id: drop the user's edit
//   await registry.delete(id);  // custom id: remove the source
//   await registry.close();     // when the owner is disposed
//
// Writes are serialized, so two concurrent saves cannot race on name
// uniqueness. `save`/`reset`/`delete` return only after `entries` reflects the
// change.
import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:rxdart/rxdart.dart';

import '../model/source_entry.dart';
import '../sources/manga_dex_source_external.dart';
import '../sources/script_source_external.dart';

/// Ids of the scripts bundled with the app, in display order.
const shippedSourceIds = [
  'asura-scans',
  'weeb-central',
  'manga-katana',
  'manhua-plus',
];

/// Name of the built-in MangaDex source; no script may take it.
const _mangaDexName = 'Manga Dex';

/// Thrown by [SourceRegistry.save] when a well-formed script is not allowed
/// (unsupported contract, locked or duplicate name). [message] is user facing.
class SourceScriptRejected implements Exception {
  final String message;

  const SourceScriptRejected(this.message);

  @override
  String toString() => 'SourceScriptRejected: $message';
}

class SourceRegistry {
  /// The native MangaDex source, always first in [values].
  static final SourceExternal _mangaDex = MangaDexSourceExternal();

  final SourceScriptDao _dao;
  final RunSourceScriptUseCase _runner;
  final Map<String, SourceScript> _shipped;
  final BehaviorSubject<List<SourceEntry>> _entries;
  List<SourceExternal> _values;
  StreamSubscription<List<SourceScriptDrift>>? _subscription;
  Future<void> _tail = Future<void>.value();

  SourceRegistry._(
    this._dao,
    this._runner,
    this._shipped,
    List<SourceEntry> initial,
  ) : _entries = BehaviorSubject.seeded(initial),
      _values = const [] {
    _values = _adapters(initial);
  }

  /// Loads the bundled scripts through [loadAsset] (path
  /// `packages/domain_manga/assets/sources/<id>.js`) and the stored rows from
  /// [dao], and keeps [entries] in sync with later [dao] changes. [runner]
  /// executes the scripts behind [values].
  static Future<SourceRegistry> create({
    required SourceScriptDao dao,
    required RunSourceScriptUseCase runner,
    required Future<String> Function(String assetPath) loadAsset,
  }) async {
    final shipped = <String, SourceScript>{};
    for (final id in shippedSourceIds) {
      final path = 'packages/domain_manga/assets/sources/$id.js';
      try {
        final script = SourceScript.parse(await loadAsset(path));
        // A bundled asset always matches the compiled-in constant; the gate
        // keeps a mismatched asset from executing if they ever drift (same
        // gate as [save], review on #194).
        if (script.contract != kSupportedSourceContract) {
          developer.log(
            'Skipping shipped source "$id": unsupported contract '
            '${script.contract} (this app supports $kSupportedSourceContract)',
            name: 'SourceRegistry',
          );
        } else {
          shipped[id] = script;
        }
      } catch (error, stackTrace) {
        developer.log(
          'Skipping shipped source "$id"',
          name: 'SourceRegistry',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    final rows = await dao.getAll();
    final registry = SourceRegistry._(
      dao,
      runner,
      shipped,
      _resolve(shipped, rows),
    );
    registry._subscription = dao.watchAll().listen(registry._publish);
    return registry;
  }

  /// Current resolved sources; replays the latest list to new listeners.
  ValueStream<List<SourceEntry>> get entries => _entries.stream;

  /// MangaDex followed by one adapter per entry, in [entries] order. Updated
  /// before [entries] emits.
  List<SourceExternal> get values => _values;

  /// The source named [name], or null (e.g. a removed or deleted source).
  SourceExternal? fromName(String name) {
    return _values.firstWhereOrNull((e) => e.name == name);
  }

  /// The source whose `baseUrl` host is [host], or null.
  SourceExternal? fromHost(String host) {
    return _values.firstWhereOrNull(
      (e) => Uri.tryParse(e.baseUrl)?.host == host,
    );
  }

  /// Whether saving [code] would create a source or replace an existing one.
  /// Throws [SourceScriptFormatException] when the header does not parse.
  SaveTarget classify(String code) {
    final script = SourceScript.parse(code);
    final existing = _entries.value.firstWhereOrNull(
      (e) => e.script.id == script.id,
    );
    return existing == null ? const NewSource() : ReplacesSource(existing);
  }

  /// Validates and stores [code], returning the resulting entry.
  ///
  /// Throws [SourceScriptFormatException] for a bad header and
  /// [SourceScriptRejected] for a contract mismatch, a changed name on an
  /// existing id, or a new id whose name is already taken. Nothing is written
  /// when it throws.
  Future<SourceEntry> save(String code) {
    return _synchronized(() async {
      final script = SourceScript.parse(code);
      if (script.contract != kSupportedSourceContract) {
        throw SourceScriptRejected(
          'Unsupported contract ${script.contract}; '
          'this app supports $kSupportedSourceContract',
        );
      }

      await _refresh();
      final entries = _entries.value;
      final existing = entries.firstWhereOrNull(
        (e) => e.script.id == script.id,
      );
      if (existing != null) {
        if (script.name != existing.script.name) {
          throw SourceScriptRejected(
            'Name is locked: expected "${existing.script.name}"',
          );
        }
      } else if (script.name == _mangaDexName ||
          entries.any((e) => e.script.name == script.name)) {
        throw SourceScriptRejected(
          'Name "${script.name}" is already used by another source',
        );
      }

      final shipped = _shipped[script.id];
      final edited = shipped != null && existing?.status != SourceStatus.custom;
      await _dao.upsert(
        SourceScriptTablesCompanion(
          id: Value(script.id),
          name: Value(script.name),
          code: Value(code),
          version: Value(script.version),
          origin: Value(
            edited
                ? SourceScriptOrigin.shippedEdited
                : SourceScriptOrigin.custom,
          ),
          // Explicit null: an absent value would keep the old base on replace.
          baseVersion: Value<int?>(edited ? shipped.version : null),
        ),
      );
      await _refresh();
      return _entries.value.firstWhere((e) => e.script.id == script.id);
    });
  }

  /// Drops the user's edit of the shipped source [id], restoring the bundled
  /// script. Throws [StateError] when [id] is not a shipped id.
  Future<void> reset(String id) {
    return _synchronized(() async {
      if (!shippedSourceIds.contains(id)) {
        throw StateError('"$id" is not a shipped source; use delete');
      }
      await _dao.remove(id);
      await _refresh();
    });
  }

  /// Removes the custom source [id]. Throws [StateError] for a shipped id.
  Future<void> delete(String id) {
    return _synchronized(() async {
      if (shippedSourceIds.contains(id)) {
        throw StateError('"$id" is a shipped source; use reset');
      }
      await _dao.remove(id);
      await _refresh();
    });
  }

  /// Stops listening to the DAO and closes [entries].
  Future<void> close() async {
    await _subscription?.cancel();
    await _entries.close();
  }

  Future<T> _synchronized<T>(Future<T> Function() action) {
    // Not a plain whenComplete: a failed earlier action must not poison the
    // queue, and the caller still sees its own action's error.
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<void> _refresh() async => _publish(await _dao.getAll());

  void _publish(List<SourceScriptDrift> rows) {
    if (_entries.isClosed) return;
    final next = _resolve(_shipped, rows);
    if (const ListEquality<SourceEntry>().equals(_entries.value, next)) return;
    _values = _adapters(next);
    _entries.add(next);
  }

  List<SourceExternal> _adapters(List<SourceEntry> entries) {
    return List.unmodifiable([
      _mangaDex,
      for (final entry in entries)
        ScriptSourceExternal(script: entry.script, runner: _runner),
    ]);
  }

  static List<SourceEntry> _resolve(
    Map<String, SourceScript> shipped,
    List<SourceScriptDrift> rows,
  ) {
    final byId = {for (final row in rows) row.id: row};

    // The entry for a shipped id with no usable stored row: the bundled
    // script keeps the source visible, usable and resettable instead of
    // letting it vanish from the registry because its stored edit is
    // unreadable or from a newer contract (review on #194).
    SourceEntry? shippedEntry(SourceScript? bundled) {
      return bundled == null
          ? null
          : SourceEntry(
            script: bundled,
            status: SourceStatus.shipped,
            shipped: bundled,
          );
    }

    SourceEntry? entry(String id) {
      final row = byId[id];
      final bundled = shipped[id];
      if (row == null) return shippedEntry(bundled);
      final SourceScript script;
      try {
        script = SourceScript.parse(row.code);
      } on SourceScriptFormatException catch (error) {
        // A stored row can only be invalid through outside tampering.
        developer.log(
          'Skipping stored source "$id" '
          '(the shipped script stays active)',
          name: 'SourceRegistry',
          error: error,
        );
        return shippedEntry(bundled);
      }
      // [save] rejects unsupported contracts; the gate is repeated at load so
      // a row written by a NEWER app version (after a contract bump) is
      // quarantined here instead of executing against an incompatible runtime
      // and failing later as per-function errors (review on #194). A bundled
      // script keeps the source alive.
      if (script.contract != kSupportedSourceContract) {
        developer.log(
          'Skipping stored source "$id": unsupported contract '
          '${script.contract} (this app supports $kSupportedSourceContract; '
          'the shipped script stays active)',
          name: 'SourceRegistry',
        );
        return shippedEntry(bundled);
      }
      final status =
          row.origin == SourceScriptOrigin.custom
              ? SourceStatus.custom
              : bundled != null && bundled.version > (row.baseVersion ?? 0)
              ? SourceStatus.updateAvailable
              : SourceStatus.modified;
      return SourceEntry(script: script, status: status, shipped: bundled);
    }

    final others =
        rows.where((r) => !shippedSourceIds.contains(r.id)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return [
      for (final id in [...shippedSourceIds, ...others.map((r) => r.id)])
        if (entry(id) case final resolved?) resolved,
    ];
  }
}
