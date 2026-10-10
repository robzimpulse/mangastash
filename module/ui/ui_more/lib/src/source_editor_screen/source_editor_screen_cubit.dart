// SourceEditorScreenCubit: drives the source editor (issue #115, spec §10 and
// §10.1) for the source [id]:
//   - [updateCode] tracks the unsaved text; registry updates never overwrite
//     unsaved edits (only an unedited editor follows the stored script).
//   - [test] parses the UNSAVED code, builds a temporary ScriptSourceExternal
//     whose page runs are forced to `runOnPage(useCache: false,
//     captureHtml: true)`, runs the selected function (search: a search term
//     goes through `searchUrl` first; a URL input is loaded as-is), applies
//     the same validators as the use cases and stores a [SourceTestRun].
//   - [copyFixPrompt] builds the FixPromptBuilder prompt from the last run,
//     running Test first when there is no page HTML yet, and copies it.
//   - [pasteAnswer] replaces the code with the script extracted from the
//     clipboard (extractScriptFromReply).
//   - [save] / [reset] go through SourceRegistry; errors land in
//     `saveError` (banner) and `message` (snackbar).
//
// Usage: `SourceEditorScreenCubit(id: id, function: fn, url: url,
// registry: ..., runner: ..., promptBuilder: ...)`; see SourceEditorScreen.
import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter/services.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'source_editor_screen_state.dart';

class SourceEditorScreenCubit extends Cubit<SourceEditorScreenState>
    with AutoSubscriptionMixin {
  /// Functions Test can run; all run inside a loaded page.
  static const List<String> functions = [
    'search',
    'manga',
    'chapters',
    'images',
    'tags',
  ];

  /// Maximum number of JSON lines kept in a [SourceTestRun].
  static const int maxJsonLines = 200;

  /// Error message passed to the fix prompt when the last run passed.
  static const String noErrorMessage = 'no error — improve or verify';

  final SourceRegistry _registry;
  final RunSourceScriptUseCase _runner;
  final FixPromptBuilder _promptBuilder;

  SourceEditorScreenCubit({
    required String id,
    String? function,
    String? url,
    required SourceRegistry registry,
    required RunSourceScriptUseCase runner,
    required FixPromptBuilder promptBuilder,
  }) : _registry = registry,
       _runner = runner,
       _promptBuilder = promptBuilder,
       super(_initial(id, function, url, registry)) {
    addSubscription(registry.entries.listen(_onEntries));
  }

  static SourceEditorScreenState _initial(
    String id,
    String? function,
    String? url,
    SourceRegistry registry,
  ) {
    final entry = _find(registry.entries.valueOrNull, id);
    final code = entry?.script.code ?? '';
    return SourceEditorScreenState(
      id: id,
      entry: entry,
      code: code,
      savedCode: code,
      function: _testable(function),
      input: url ?? '',
    );
  }

  static SourceEntry? _find(List<SourceEntry>? entries, String id) {
    return entries?.firstWhereOrNull((e) => e.script.id == id);
  }

  /// Maps a failing function name (possibly a URL builder) to the page
  /// function Test runs for it; unknown or missing names test `search`.
  static String _testable(String? function) {
    return switch (function) {
      'searchUrl' => 'search',
      'chaptersUrl' => 'chapters',
      'tagsUrl' => 'tags',
      final String name when functions.contains(name) => name,
      _ => 'search',
    };
  }

  void _onEntries(List<SourceEntry> entries) {
    final entry = _find(entries, state.id);
    if (entry == null) {
      emit(state.copyWith(clearEntry: true));
      return;
    }
    final stored = entry.script.code;
    emit(
      state.copyWith(
        entry: entry,
        savedCode: stored,
        // Follow the stored script only when there are no unsaved edits.
        code: state.hasChanges ? null : stored,
      ),
    );
  }

  /// Records the editor text.
  void updateCode(String code) {
    if (code == state.code) return;
    emit(state.copyWith(code: code));
  }

  /// Selects the function Test runs.
  void selectFunction(String function) {
    emit(state.copyWith(function: _testable(function)));
  }

  /// Records the Test input (search term or URL).
  void updateInput(String input) => emit(state.copyWith(input: input));

  /// Marks the current snackbar message as shown.
  void clearMessage() => emit(state.copyWith(clearMessage: true));

  /// Runs the selected function of the unsaved code; see the file header.
  Future<void> test() async {
    if (state.isRunning) return;
    emit(state.copyWith(isRunning: true, clearHint: true));
    final run = await _run(
      code: state.code,
      function: state.function,
      input: state.input.trim(),
    );
    emit(state.copyWith(isRunning: false, lastRun: run));
  }

  /// Copies the fix prompt for the last run (running Test first when there is
  /// no page HTML yet) to the clipboard.
  Future<void> copyFixPrompt() async {
    if (state.isRunning) return;
    if (state.lastRun?.html == null) await test();
    final run = state.lastRun;
    if (run == null) return;
    try {
      final prompt = await _promptBuilder.build(
        code: state.code,
        function: run.function,
        url: run.url ?? state.input.trim(),
        errorMessage: run.problem ?? noErrorMessage,
        html: run.html ?? '',
      );
      await Clipboard.setData(ClipboardData(text: prompt));
      emit(
        state.copyWith(message: 'Prompt copied — paste it into any chatbot'),
      );
    } catch (error) {
      emit(state.copyWith(message: error.toString()));
    }
  }

  /// Replaces the code with the script found in the clipboard.
  Future<void> pasteAnswer() async {
    final raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    final code = raw == null ? null : extractScriptFromReply(raw);
    if (code == null || code.isEmpty) {
      emit(state.copyWith(message: 'No script found in the clipboard'));
      return;
    }
    emit(state.copyWith(code: code, hint: 'Run Test before saving'));
  }

  /// Stores the unsaved code. Returns whether it was saved; a rejection is
  /// published as `saveError` and the unsaved text is kept.
  Future<bool> save() async {
    final code = state.code;
    emit(state.copyWith(clearSaveError: true));
    try {
      final entry = await _registry.save(code);
      emit(state.copyWith(entry: entry, savedCode: code, message: 'Saved'));
      return true;
    } catch (error) {
      emit(state.copyWith(saveError: _describe(error)));
      return false;
    }
  }

  /// Drops the user's edit and loads the built-in script into the editor.
  Future<void> reset() async {
    try {
      await _registry.reset(state.id);
      final entry = _find(_registry.entries.valueOrNull, state.id);
      final code = entry?.script.code ?? state.code;
      emit(
        state.copyWith(
          entry: entry,
          code: code,
          savedCode: code,
          clearHint: true,
          clearSaveError: true,
          message: 'Restored the built-in script',
        ),
      );
    } catch (error) {
      emit(state.copyWith(message: _describe(error)));
    }
  }

  Future<SourceTestRun> _run({
    required String code,
    required String function,
    required String input,
  }) async {
    final watch = Stopwatch()..start();
    final runner = _CapturingRunner(_runner);
    String? url;
    SourceTestRun result({
      String? error,
      int? line,
      String? validation,
      String? summary,
      String? html,
    }) {
      return SourceTestRun(
        function: function,
        url: url,
        json: _json(runner.last),
        error: error,
        line: line,
        validation: validation,
        summary: summary,
        elapsed: watch.elapsed,
        html: html ?? runner.last?.html,
      );
    }

    try {
      final script = SourceScript.parse(code);
      final source = ScriptSourceExternal(script: script, runner: runner);
      final name = script.name;
      final isUrl = _isUrl(input);
      if (function != 'search' && function != 'tags' && !isUrl) {
        return result(error: 'Enter a page URL to test $function');
      }
      switch (function) {
        case 'search':
          final term = isUrl || input.isEmpty ? null : input;
          url =
              isUrl
                  ? input
                  : await source.searchUrl(
                    parameter: SearchMangaParameter(title: term, page: 1),
                  );
          final page = await source.search(
            url: url,
            searchTerm: term,
            useCache: false,
          );
          final cards = page.items.requireCardFields(source: name, url: url);
          return result(summary: _count(cards.length, 'item'));
        case 'manga':
          url = input;
          final manga = await source.manga(url: input, useCache: false);
          manga.requireDetailFields(source: name, url: input);
          return result(summary: 'Valid');
        case 'chapters':
          url = input;
          final rows = await source.chapters(url: input, useCache: false);
          final valid = rows.requireChapterFields(source: name, url: input);
          return result(summary: _count(valid.length, 'chapter'));
        case 'images':
          url = input;
          final images = await source.images(url: input, useCache: false);
          requireChapterImages(images, source: name, url: input);
          return result(summary: _count(images.length, 'image'));
        default:
          url = isUrl ? input : await source.tagsUrl();
          final tags = await source.tags(url: url, useCache: false);
          return result(summary: _count(tags.length, 'tag'));
      }
    } on SourceScriptFormatException catch (e) {
      return result(error: e.message);
    } on SourceScriptException catch (e) {
      url = e.url ?? url;
      final message = e.timedOut ? 'Timed out: ${e.message}' : e.message;
      return result(error: message, line: e.line, html: e.html);
    } on FailedParsingHtmlException catch (e) {
      // No missing fields = the page itself failed to load, not validation.
      if (e.missingFields.isEmpty) return result(error: e.toString());
      return result(validation: 'missing ${e.missingFields.join(', ')}');
    } catch (e) {
      return result(error: e.toString());
    }
  }

  static bool _isUrl(String input) {
    final uri = Uri.tryParse(input);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String _count(int count, String noun) {
    return 'Valid — $count ${count == 1 ? noun : '${noun}s'}';
  }

  static String? _json(ScriptRunResult? result) {
    if (result == null) return null;
    final lines = const JsonEncoder.withIndent(
      '  ',
    ).convert(result.value).split('\n');
    if (lines.length <= maxJsonLines) return lines.join('\n');
    final more = lines.length - maxJsonLines;
    return [...lines.take(maxJsonLines), '… $more more lines'].join('\n');
  }

  static String _describe(Object error) {
    return switch (error) {
      SourceScriptFormatException(:final message) => message,
      SourceScriptRejected(:final message) => message,
      _ => error.toString(),
    };
  }
}

/// Runner for Test: page runs never use the cache and always capture the
/// page HTML; the last page result is kept for the JSON view and the prompt.
class _CapturingRunner implements RunSourceScriptUseCase {
  final RunSourceScriptUseCase _inner;

  ScriptRunResult? last;

  _CapturingRunner(this._inner);

  @override
  Future<ScriptRunResult> runOnPage({
    required String url,
    required String code,
    required String function,
    required String baseUrl,
    String? searchTerm,
    Duration? timeout,
    bool useCache = true,
    bool captureHtml = false,
  }) async {
    final result = await _inner.runOnPage(
      url: url,
      code: code,
      function: function,
      baseUrl: baseUrl,
      searchTerm: searchTerm,
      timeout: timeout,
      useCache: false,
      captureHtml: true,
    );
    last = result;
    return result;
  }

  @override
  Future<Object?> runOnBlank({
    required String code,
    required String function,
    required String baseUrl,
    List<Object?> args = const [],
    Duration? timeout,
  }) {
    return _inner.runOnBlank(
      code: code,
      function: function,
      baseUrl: baseUrl,
      args: args,
      timeout: timeout,
    );
  }

  @override
  Future<void> evict({required String url}) => _inner.evict(url: url);
}
