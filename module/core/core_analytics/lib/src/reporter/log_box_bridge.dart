import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'crash_reporter.dart';

/// Forwards new [LogBox] entries to a [CrashReporter]: error-level entries
/// become non-fatal reports, everything else becomes breadcrumbs, and both
/// carry context keys (app version/build plus whatever the entry's `extra`
/// holds) via [CrashReporter.setKey].
///
/// Usage: the registrar constructs it with the registered [LogBox] and
/// [CrashReporter] singletons, awaits [start], and registers it so
/// `locator.reset()` runs [close]. The fatal hooks in `main.dart` call
/// [markFatal] right before `reportFatal` so the matching LogBox entry is not
/// forwarded again as a non-fatal.
///
/// The subscription rides `LogBox.storage.liveStorage`, a [ChangeNotifier]
/// that notifies on every write; new entries are detected by diffing entry
/// identities, so merged updates with new content are forwarded while pure
/// re-notifications are not.
class LogBoxBridge {
  /// Creates a bridge over [logBox] forwarding to [reporter].
  ///
  /// [contextKeys] resolves the session-wide context keys attached to every
  /// report, e.g. app version/build. It defaults to a `package_info_plus`-
  /// backed closure that resolves to an empty map when platform channels are
  /// unavailable (tests, broken configs) — inject a stub for deterministic
  /// tests.
  LogBoxBridge({
    required LogBox logBox,
    required CrashReporter reporter,
    Future<Map<String, String>> Function()? contextKeys,
  }) : _logBox = logBox,
       _reporter = reporter,
       _contextKeys = contextKeys ?? _packageInfoContextKeys;

  /// The LogBox whose new entries are forwarded.
  final LogBox _logBox;

  /// Where entries are forwarded to.
  final CrashReporter _reporter;

  /// Resolves the session-wide context keys, awaited once in [start].
  final Future<Map<String, String>> Function() _contextKeys;

  /// Entry `extra` keys attached as crash-report keys when present.
  static const List<String> _extraContextKeys = [
    'source',
    'mangaId',
    'chapterId',
  ];

  /// Maximum fatal identities remembered for dedupe; the oldest is dropped
  /// first, keeping the set small while covering realistic fatal bursts.
  static const int _maxFatalIdentities = 32;

  /// [FirebaseCrashReporter]'s guard logs its own failures under this name.
  /// Forwarding those entries back into the reporter would loop forever
  /// (report fails → guard logs → bridge reports → …), so they are skipped.
  /// Keep in sync with `FirebaseCrashReporter._guard`.
  static const String _reporterLogName = 'FirebaseCrashReporter';

  /// Identities already reported through the fatal path, oldest first.
  final Queue<String> _fatalIdentities = Queue<String>();

  /// Context keys resolved once by [start], applied to every report.
  Map<String, String> _contextKeyCache = const {};

  /// Identities of entries already forwarded, rebuilt from storage on every
  /// notification so it never outgrows the storage itself.
  Set<String> _forwardedKeys = {};

  /// Guards against double subscription and forwarding after [close].
  bool _started = false;
  bool _closed = false;

  /// Marks [error] and [stack] as already reported through the fatal path so
  /// the matching LogBox entry is skipped instead of double-reported as a
  /// non-fatal. Call it wherever `reportFatal` is invoked.
  void markFatal(Object error, StackTrace stack) {
    final identity = _fatalIdentity(error.toString(), stack.toString());
    _fatalIdentities.add(identity);
    while (_fatalIdentities.length > _maxFatalIdentities) {
      _fatalIdentities.removeFirst();
    }
  }

  /// Resolves the context keys, applies them as session-wide report keys (so
  /// fatals reported directly by `main.dart` carry them too), snapshots the
  /// existing entries as already forwarded, and subscribes to new entries.
  Future<void> start() async {
    if (_started || _closed) {
      return;
    }
    _started = true;

    _contextKeyCache = await _loadContextKeys();
    for (final entry in _contextKeyCache.entries) {
      _reporter.setKey(entry.key, entry.value);
    }

    // History logged before startup is context, not news: never re-report it.
    _forwardedKeys = _logBox.storage.liveStorage.data.map(_forwardKey).toSet();
    _logBox.storage.liveStorage.addListener(_onStorageChanged);
  }

  /// Stops forwarding entries and releases the subscription. Safe to call
  /// more than once and after the storage has been disposed.
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    try {
      _logBox.storage.liveStorage.removeListener(_onStorageChanged);
    } catch (error) {
      // The storage may already be disposed; closing must never throw.
      debugPrint('LogBoxBridge failed to detach from LogBox: $error');
    }
    _forwardedKeys = {};
    _fatalIdentities.clear();
  }

  /// Diff `data` against the forwarded identities and forward what is new.
  ///
  /// Runs synchronously inside LogBox's write path, so any failure is
  /// swallowed after printing: forwarding must never break logging. LogBox is
  /// not used for these failures to avoid re-entering this listener.
  void _onStorageChanged() {
    if (_closed) {
      return;
    }
    try {
      final entries = _logBox.storage.liveStorage.data;
      final forwarded = <String>{};
      for (final entry in entries) {
        final key = _forwardKey(entry);
        forwarded.add(key);
        if (_forwardedKeys.contains(key)) {
          continue;
        }
        _forwardEntry(entry);
      }
      _forwardedKeys = forwarded;
    } catch (error) {
      debugPrint('LogBoxBridge failed to forward LogBox entries: $error');
    }
  }

  /// Forwards one entry: error-level [LogEntryModel]s as non-fatals (skipping
  /// already-fatally-reported and reporter-authored ones), everything else as
  /// breadcrumbs.
  void _forwardEntry(EntryModel entry) {
    if (entry is LogEntryModel) {
      if (entry.name == _reporterLogName) {
        return;
      }
      final error = entry.error;
      if (error != null) {
        final identity = _fatalIdentity(error, entry.stackTrace);
        if (_fatalIdentities.contains(identity)) {
          return;
        }
        _applyContextKeys(entry);
        _reporter.reportNonFatal(
          error,
          StackTrace.fromString(entry.stackTrace ?? ''),
          reason: '${entry.name ?? 'Log'}: ${entry.message}',
        );
        return;
      }
      _reporter.logBreadcrumb('${entry.name ?? 'Log'}: ${entry.message}');
      return;
    }
    if (entry is TraceLogEntryModel) {
      _reporter.logBreadcrumb('${entry.display()}: ${entry.name}');
      return;
    }
    _reporter.logBreadcrumb('${entry.display()}: ${entry.id}');
  }

  /// Applies the session-wide context keys and the keys the entry's `extra`
  /// actually carries onto the next crash report.
  void _applyContextKeys(LogEntryModel entry) {
    for (final contextKey in _contextKeyCache.entries) {
      _reporter.setKey(contextKey.key, contextKey.value);
    }
    final extra = entry.extra;
    if (extra == null) {
      return;
    }
    for (final name in _extraContextKeys) {
      final value = extra[name];
      if (value is String) {
        _reporter.setKey(name, value);
      }
    }
  }

  /// Identity of an entry's current content: a new id or a merged update with
  /// new error/stack/message content forwards again, pure re-notifications do
  /// not. Non-[LogEntryModel]s merge in place under one id, so the id alone
  /// deduplicates their repeated updates.
  String _forwardKey(EntryModel entry) {
    if (entry is LogEntryModel) {
      return '${entry.id}|${entry.message}|${entry.error}|${entry.stackTrace}';
    }
    return entry.id;
  }

  /// Identity shared by [markFatal]'s arguments and a LogBox entry's stored
  /// strings — LogBox persists `error.toString()`/`stackTrace.toString()`.
  String _fatalIdentity(String error, String? stackTrace) {
    return '$error\u0000$stackTrace';
  }

  /// Resolves [contextKeys] without ever throwing: context keys are
  /// best-effort and must not block or crash startup.
  Future<Map<String, String>> _loadContextKeys() async {
    try {
      return await _contextKeys();
    } catch (error) {
      debugPrint('LogBoxBridge failed to resolve context keys: $error');
      return const {};
    }
  }

  /// Default [contextKeys]: app version and build number from
  /// `package_info_plus`, empty when the plugin is unavailable.
  static Future<Map<String, String>> _packageInfoContextKeys() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return {'appVersion': info.version, 'appBuild': info.buildNumber};
    } catch (error) {
      // Platform channels are unavailable (unit tests, desktop shells).
      return const {};
    }
  }
}
