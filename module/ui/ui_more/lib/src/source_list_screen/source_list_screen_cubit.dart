// SourceListScreenCubit: drives the source list screen (issue #115, spec §8).
// It mirrors SourceRegistry.entries and the enabled sources, toggles sources on
// and off through UpdateSourcesUseCase, resets/deletes sources through the
// registry, and runs the clipboard "Add source" flow in two steps so the UI can
// show a trust dialog in between:
//   1. [inspectClipboard] extracts + parses the script and classifies it,
//   2. [add] saves it (a brand-new source is also enabled).
//
// Errors (SourceScriptFormatException / SourceScriptRejected / anything else)
// become the one-shot [SourceListScreenState.message]; the UI shows it and calls
// [clearMessage].
//
// Usage: `SourceListScreenCubit(registry: ..., listenSourcesUseCase: ...,
// updateSourcesUseCase: ...)`; see SourceListScreen for the UI side.
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'source_list_screen_state.dart';

/// A script read from the clipboard, parsed and waiting for the user's trust
/// confirmation. [replaces] is the entry that saving would overwrite, if any.
class PendingSource {
  final String code;
  final SourceScript script;
  final SourceEntry? replaces;

  const PendingSource({
    required this.code,
    required this.script,
    this.replaces,
  });
}

class SourceListScreenCubit extends Cubit<SourceListScreenState>
    with AutoSubscriptionMixin {
  final SourceRegistry _registry;
  final ListenSourcesUseCase _listenSourcesUseCase;
  final UpdateSourcesUseCase _updateSourcesUseCase;

  SourceListScreenCubit({
    required SourceRegistry registry,
    required ListenSourcesUseCase listenSourcesUseCase,
    required this._updateSourcesUseCase,
    SourceListScreenState initialState = const SourceListScreenState(),
  }) : _registry = registry,
       _listenSourcesUseCase = listenSourcesUseCase,
       super(
         initialState.copyWith(
           entries: registry.entries.valueOrNull,
           builtInNames: _builtInNames(registry),
           enabledNames: _names(listenSourcesUseCase.sourceStateStream),
         ),
       ) {
    addSubscription(
      registry.entries.distinct().listen(
        (entries) => emit(
          state.copyWith(
            entries: entries,
            builtInNames: _builtInNames(registry),
          ),
        ),
      ),
    );
    addSubscription(
      listenSourcesUseCase.sourceStateStream.distinct().listen(
        (sources) =>
            emit(state.copyWith(enabledNames: {...sources.map((e) => e.name)})),
      ),
    );
  }

  static List<String> _builtInNames(SourceRegistry registry) {
    return [
      for (final source in registry.values)
        if (source.builtIn) source.name,
    ];
  }

  static Set<String> _names(ValueStream<List<SourceExternal>> stream) {
    return {...?stream.valueOrNull?.map((e) => e.name)};
  }

  List<SourceExternal> get _enabled {
    return _listenSourcesUseCase.sourceStateStream.valueOrNull ?? const [];
  }

  /// Enables or disables the source called [name].
  Future<void> toggle({required String name, required bool enabled}) async {
    final others = _enabled.where((e) => e.name != name).toList();
    if (!enabled) return _updateEnabled(others);
    final source = _registry.fromName(name);
    if (source == null) return;
    await _updateEnabled([...others, source]);
  }

  /// Restores the built-in script of the shipped source [id].
  Future<void> reset({required String id}) async {
    try {
      await _registry.reset(id);
    } catch (error) {
      emit(state.copyWith(message: _describe(error)));
    }
  }

  /// Deletes the custom source [id] called [name] and drops it from the
  /// enabled sources.
  Future<void> delete({required String id, required String name}) async {
    try {
      await _registry.delete(id);
      await _updateEnabled(_enabled.where((e) => e.name != name).toList());
    } catch (error) {
      emit(state.copyWith(message: _describe(error)));
    }
  }

  /// Reads the clipboard and prepares a script to add. Returns null (after
  /// publishing a message) when the clipboard is empty or holds no valid
  /// script. The raw clipboard text is used when no script block is found in it.
  Future<PendingSource?> inspectClipboard() async {
    try {
      final raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (raw == null || raw.trim().isEmpty) {
        emit(state.copyWith(message: 'Clipboard is empty'));
        return null;
      }
      final extracted = extractScriptFromReply(raw);
      final code = (extracted == null || extracted.isEmpty) ? raw : extracted;
      final script = SourceScript.parse(code);
      final target = _registry.classify(code);
      return PendingSource(
        code: code,
        script: script,
        replaces: switch (target) {
          ReplacesSource(:final entry) => entry,
          NewSource() => null,
        },
      );
    } catch (error) {
      emit(state.copyWith(message: _describe(error)));
      return null;
    }
  }

  /// Saves [pending]; a source that did not exist before is also enabled.
  Future<void> add(PendingSource pending) async {
    try {
      await _registry.save(pending.code);
      if (pending.replaces != null) return;
      final name = pending.script.name;
      final source = _registry.fromName(name);
      if (source == null) return;
      await _updateEnabled([..._enabled.where((e) => e.name != name), source]);
    } catch (error) {
      emit(state.copyWith(message: _describe(error)));
    }
  }

  /// Marks the current message as shown.
  void clearMessage() => emit(state.copyWith(clearMessage: true));

  Future<void> _updateEnabled(List<SourceExternal> sources) async {
    emit(state.copyWith(enabledNames: {...sources.map((e) => e.name)}));
    await _updateSourcesUseCase.updateSources(sources: sources);
  }

  static String _describe(Object error) {
    return switch (error) {
      SourceScriptFormatException(:final message) => message,
      SourceScriptRejected(:final message) => message,
      _ => error.toString(),
    };
  }
}
