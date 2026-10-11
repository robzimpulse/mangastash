/// Widget tests for SourceEditorScreen (issue #115, spec §10/§10.1): the
/// editor field's smart-punctuation settings, Test (script errors with their
/// line, validation failures, header parse errors), Copy fix prompt (runs a
/// capturing Test first when there is no page HTML yet), Paste answer, Save
/// (rejections as a banner, failing-test confirmation), Reset to built-in and
/// the missing-source error state.
///
/// Run: `cd module/ui/ui_more && fvm flutter test test/src/source_editor_screen`.
/// ScaffoldScreen shimmers forever, so interactions are followed by
/// [pumpFrames] instead of pumpAndSettle (see CLAUDE.md).
import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_more/src/source_editor_screen/source_editor_screen.dart';
import 'package:ui_more/src/source_editor_screen/source_editor_screen_cubit.dart';

class _MockSourceRegistry extends Mock implements SourceRegistry {}

class _MockRunner extends Mock implements RunSourceScriptUseCase {}

String _code({
  String id = 'asura-scans',
  String name = 'Asura Scans',
  String body = 'const source = {};',
}) {
  return '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", '
      '"baseUrl": "https://asurascans.com", "version": 1, "contract": 1, '
      '"hosts": ["asurascans.com"]}\n'
      '// ==/MangaStashSource==\n'
      '$body\n';
}

SourceEntry _entry(SourceStatus status, {String? code, String? shippedCode}) {
  return SourceEntry(
    script: SourceScript.parse(code ?? _code()),
    status: status,
    shipped: SourceScript.parse(shippedCode ?? _code()),
  );
}

/// A search result with one valid card.
const Map<String, Object> _oneCard = {
  'items': [
    {'title': 'Solo', 'webUrl': 'https://asurascans.com/comics/solo'},
  ],
};

void main() {
  late _MockSourceRegistry registry;
  late _MockRunner runner;
  late BehaviorSubject<List<SourceEntry>> entries;
  late List<String> calls;
  late String? clipboardText;
  late String? copiedText;
  SourceEditorScreenCubit? cubit;

  setUp(() {
    registry = _MockSourceRegistry();
    runner = _MockRunner();
    entries = BehaviorSubject.seeded([_entry(SourceStatus.modified)]);
    calls = [];
    clipboardText = null;
    copiedText = null;
    when(() => registry.entries).thenAnswer((_) => entries.stream);
    when(() => runner.evict(url: any(named: 'url'))).thenAnswer((_) async {});
    when(
      () => runner.runOnBlank(
        code: any(named: 'code'),
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        args: any(named: 'args'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async {
      calls.add('runOnBlank');
      return 'https://asurascans.com/browse';
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            final text = clipboardText;
            return text == null ? null : <String, dynamic>{'text': text};
          }
          if (call.method == 'Clipboard.setData') {
            calls.add('setData');
            copiedText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await cubit?.close();
    cubit = null;
    await entries.close();
  });

  /// Stubs runOnPage to return [value] with [html], or to throw [error];
  /// when [gate] is given the run waits for it to complete.
  void stubPage({
    Object? value,
    String? html,
    Object? error,
    Completer<void>? gate,
  }) {
    when(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: any(named: 'code'),
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: any(named: 'useCache'),
        captureHtml: any(named: 'captureHtml'),
      ),
    ).thenAnswer((_) async {
      calls.add('runOnPage');
      await gate?.future;
      if (error != null) throw error;
      return ScriptRunResult(
        value: value,
        html: html,
        elapsed: const Duration(milliseconds: 1200),
      );
    });
  }

  Future<void> pumpFrames(WidgetTester tester, {int count = 4}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    String id = 'asura-scans',
    String? function,
    String? url,
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final created = SourceEditorScreenCubit(
      id: id,
      function: function,
      url: url,
      registry: registry,
      runner: runner,
      promptBuilder: FixPromptBuilder(
        loadAsset: (_) async => 'FN={{function}} ERR={{error}} URL={{url}}',
      ),
    );
    cubit = created;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SourceEditorScreenCubit>.value(
          value: created,
          child: const SourceEditorScreen(),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  TextField editorField(WidgetTester tester) {
    return tester.widget<TextField>(find.byKey(SourceEditorScreen.editorKey));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await pumpFrames(tester);
  }

  testWidgets('editor field disables smart punctuation and suggestions', (
    tester,
  ) async {
    await pumpScreen(tester);

    final field = editorField(tester);
    expect(field.smartQuotesType, SmartQuotesType.disabled);
    expect(field.smartDashesType, SmartDashesType.disabled);
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
    expect(field.maxLines, isNull);
    expect(field.keyboardType, TextInputType.multiline);
    expect(field.controller!.text, _code());
  });

  testWidgets('shows the locked name read-only', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Asura Scans'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('paste answer replaces the text with the js block', (
    tester,
  ) async {
    final pasted = _code(body: 'const source = { fixed: true };');
    clipboardText = 'Sure, here it is:\n```js\n$pasted```\nGood luck!';
    await pumpScreen(tester);

    await tapText(tester, 'Paste answer');

    final controller = editorField(tester).controller!;
    expect(controller.text, pasted.trim());
    expect(controller.selection, const TextSelection.collapsed(offset: 0));
    expect(find.text('Run Test before saving'), findsOneWidget);
  });

  testWidgets('rapid typing is not overwritten by older emitted code', (
    tester,
  ) async {
    await pumpScreen(tester);
    final controller = editorField(tester).controller!;
    final base = controller.text;

    // Several edits in a row without letting the cubit's stream deliver the
    // earlier emissions (what a fast IME burst does): the listener sees stale
    // states and must not write them back (that ping-pong froze the UI).
    for (final tail in ['a', 'ab', 'abc', 'abcd']) {
      controller.value = TextEditingValue(
        text: '$base$tail',
        selection: TextSelection.collapsed(offset: base.length + tail.length),
      );
    }
    await pumpFrames(tester);

    expect(controller.text, '${base}abcd');
    expect(cubit!.state.code, '${base}abcd');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: base.length + 4),
    );
  });

  testWidgets('entering text several times in a row keeps the last text', (
    tester,
  ) async {
    await pumpScreen(tester);
    final controller = editorField(tester).controller!;
    final base = controller.text;
    final field = find.byKey(SourceEditorScreen.editorKey);

    await tester.enterText(field, '${base}x');
    await tester.enterText(field, '${base}xy');
    await tester.enterText(field, '${base}xyz');
    await pumpFrames(tester);

    expect(controller.text, '${base}xyz');
    expect(cubit!.state.code, '${base}xyz');
  });

  testWidgets('paste after typing still replaces the text', (tester) async {
    final pasted = _code(body: 'const source = { fixed: true };');
    clipboardText = '```js\n$pasted```';
    await pumpScreen(tester);
    final controller = editorField(tester).controller!;
    controller.text = '${controller.text}typed';
    await pumpFrames(tester);

    await tapText(tester, 'Paste answer');

    expect(controller.text, pasted.trim());
    expect(controller.selection.isValid, isTrue);
    expect(
      controller.selection.baseOffset,
      inInclusiveRange(0, controller.text.length),
    );
  });

  testWidgets('paste answer without a script shows a snackbar', (tester) async {
    clipboardText = 'I could not fix it, sorry.';
    await pumpScreen(tester);

    await tapText(tester, 'Paste answer');

    expect(find.text('No script found in the clipboard'), findsOneWidget);
    expect(editorField(tester).controller!.text, _code());
  });

  testWidgets('test shows the script error with its line', (tester) async {
    stubPage(
      error: const SourceScriptException(
        function: 'manga',
        message: 'x is null',
        line: 12,
      ),
    );
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );

    await tapText(tester, 'Test');

    expect(find.textContaining('line 12'), findsOneWidget);
    expect(find.textContaining('x is null'), findsOneWidget);
    verify(
      () => runner.runOnPage(
        url: 'https://asurascans.com/comics/a',
        code: _code(),
        function: 'manga',
        baseUrl: 'https://asurascans.com',
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: false,
        captureHtml: true,
      ),
    ).called(1);
  });

  testWidgets('test shows the JSON, elapsed time and validation failure', (
    tester,
  ) async {
    stubPage(value: {'title': ''});
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );

    await tapText(tester, 'Test');

    expect(find.textContaining('"title": ""'), findsOneWidget);
    expect(find.textContaining('missing title'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ ms')), findsOneWidget);
  });

  testWidgets('a page load failure shows as an error, not validation', (
    tester,
  ) async {
    stubPage(error: FailedParsingHtmlException('https://asurascans.com/x'));
    await pumpScreen(
      tester,
      function: 'images',
      url: 'https://asurascans.com/x',
    );

    await tapText(tester, 'Test');

    expect(find.text('Error'), findsOneWidget);
    expect(find.textContaining('Validation failed'), findsNothing);
  });

  testWidgets('test of search computes the search URL first', (tester) async {
    stubPage(
      value: {
        'items': [
          {'title': 'Solo', 'webUrl': 'https://asurascans.com/comics/solo'},
        ],
      },
    );
    await pumpScreen(tester);

    await tester.enterText(find.byKey(SourceEditorScreen.inputKey), 'solo');
    await tapText(tester, 'Test');

    expect(calls, ['runOnBlank', 'runOnPage']);
    verify(
      () => runner.runOnPage(
        url: 'https://asurascans.com/browse',
        code: any(named: 'code'),
        function: 'search',
        baseUrl: any(named: 'baseUrl'),
        searchTerm: 'solo',
        timeout: any(named: 'timeout'),
        useCache: false,
        captureHtml: true,
      ),
    ).called(1);
    expect(find.textContaining('Valid'), findsOneWidget);
  });

  testWidgets('test with a broken header shows the parse error inline', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(SourceEditorScreen.editorKey),
      'const source = {};',
    );
    await pumpFrames(tester);
    await tapText(tester, 'Test');

    expect(
      find.text('Script must start with "// ==MangaStashSource==" header'),
      findsOneWidget,
    );
    verifyNever(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: any(named: 'code'),
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: any(named: 'useCache'),
        captureHtml: any(named: 'captureHtml'),
      ),
    );
  });

  testWidgets('copy fix prompt without a run tests first, then copies', (
    tester,
  ) async {
    stubPage(value: _oneCard, html: '<html>page</html>');
    await pumpScreen(tester);

    await tapText(tester, 'Copy fix prompt');

    expect(calls, ['runOnBlank', 'runOnPage', 'setData']);
    verify(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: any(named: 'code'),
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: false,
        captureHtml: true,
      ),
    ).called(1);
    expect(
      copiedText,
      'FN=search ERR=no error — improve or verify '
      'URL=https://asurascans.com/browse',
    );
    expect(find.text('Prompt copied — paste it into any chatbot'), findsOne);
  });

  testWidgets('a search with 0 items fails and feeds the prompt', (
    tester,
  ) async {
    stubPage(value: {'items': <Object>[]}, html: '<html>empty</html>');
    await pumpScreen(tester);

    await tapText(tester, 'Test');
    expect(
      find.text('Validation failed: search returned 0 items'),
      findsOneWidget,
    );

    await tapText(tester, 'Copy fix prompt');
    expect(
      copiedText,
      'FN=search ERR=search returned 0 items '
      'URL=https://asurascans.com/browse',
    );
  });

  testWidgets('copy fix prompt re-runs Test after the code changed', (
    tester,
  ) async {
    stubPage(value: _oneCard, html: '<html>page</html>');
    await pumpScreen(tester);
    await tapText(tester, 'Test');

    final edited = _code(body: 'const source = { v: 2 };');
    await tester.enterText(find.byKey(SourceEditorScreen.editorKey), edited);
    await pumpFrames(tester);
    calls.clear();
    await tapText(tester, 'Copy fix prompt');

    expect(calls, ['runOnBlank', 'runOnPage', 'setData']);
    verify(
      () => runner.runOnPage(
        url: any(named: 'url'),
        code: edited,
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        searchTerm: any(named: 'searchTerm'),
        timeout: any(named: 'timeout'),
        useCache: false,
        captureHtml: true,
      ),
    ).called(1);
  });

  testWidgets('copy fix prompt re-runs Test after the input changed', (
    tester,
  ) async {
    stubPage(value: _oneCard, html: '<html>page</html>');
    await pumpScreen(tester);
    await tapText(tester, 'Test');

    await tester.enterText(find.byKey(SourceEditorScreen.inputKey), 'solo');
    await pumpFrames(tester);
    calls.clear();
    await tapText(tester, 'Copy fix prompt');

    expect(calls, ['runOnBlank', 'runOnPage', 'setData']);
  });

  testWidgets('copy fix prompt re-runs Test after the function changed', (
    tester,
  ) async {
    stubPage(value: {'title': 'Solo'}, html: '<html>page</html>');
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );
    await tapText(tester, 'Test');

    await tester.tap(find.byType(DropdownButton<String>));
    await pumpFrames(tester);
    await tapText(tester, 'chapters');
    calls.clear();
    await tapText(tester, 'Copy fix prompt');

    expect(calls, ['runOnPage', 'setData']);
    expect(copiedText, startsWith('FN=chapters '));
  });

  testWidgets('a failing URL builder is named and no page URL is sent', (
    tester,
  ) async {
    when(
      () => runner.runOnBlank(
        code: any(named: 'code'),
        function: any(named: 'function'),
        baseUrl: any(named: 'baseUrl'),
        args: any(named: 'args'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer(
      (_) async =>
          throw const SourceScriptException(
            function: 'searchUrl',
            message: 'params is undefined',
            line: 3,
          ),
    );
    await pumpScreen(tester);
    await tester.enterText(find.byKey(SourceEditorScreen.inputKey), 'solo');
    await pumpFrames(tester);

    await tapText(tester, 'Copy fix prompt');

    expect(find.text('Error in searchUrl at line 3'), findsOneWidget);
    expect(
      copiedText,
      'FN=searchUrl ERR=line 3: params is undefined URL=(no page loaded)',
    );
  });

  testWidgets('test runs never evict the production cache', (tester) async {
    // A list where an object is expected makes the adapter evict the URL.
    stubPage(value: <Object>[1, 2]);
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );

    await tapText(tester, 'Test');

    expect(find.textContaining('Invalid result'), findsOneWidget);
    verifyNever(() => runner.evict(url: any(named: 'url')));
  });

  testWidgets('copy fix prompt reuses the last run and its error', (
    tester,
  ) async {
    stubPage(
      error: const SourceScriptException(
        function: 'manga',
        message: 'x is null',
        line: 12,
        html: '<html>broken</html>',
      ),
    );
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );
    await tapText(tester, 'Test');
    calls.clear();

    await tapText(tester, 'Copy fix prompt');

    expect(calls, ['setData']);
    expect(
      copiedText,
      'FN=manga ERR=line 12: x is null URL=https://asurascans.com/comics/a',
    );
  });

  testWidgets('save with a rejected name shows a banner and keeps the text', (
    tester,
  ) async {
    when(() => registry.save(any())).thenAnswer(
      (_) async =>
          throw const SourceScriptRejected(
            'Name is locked: expected "Asura Scans"',
          ),
    );
    final renamed = _code(name: 'Asura Scans 2');
    await pumpScreen(tester);

    await tester.enterText(find.byKey(SourceEditorScreen.editorKey), renamed);
    await pumpFrames(tester);
    await tester.tap(find.byTooltip('Save'));
    await pumpFrames(tester);

    verify(() => registry.save(renamed)).called(1);
    expect(find.textContaining('Name is locked'), findsOneWidget);
    expect(editorField(tester).controller!.text, renamed);
  });

  testWidgets('save rejects a changed id and keeps the text', (tester) async {
    final forked = _code(id: 'asura-scans-fixed');
    await pumpScreen(tester);

    await tester.enterText(find.byKey(SourceEditorScreen.editorKey), forked);
    await pumpFrames(tester);
    await tester.tap(find.byTooltip('Save'));
    await pumpFrames(tester);

    expect(find.text('Id is locked: expected "asura-scans"'), findsOneWidget);
    verifyNever(() => registry.save(any()));
    expect(editorField(tester).controller!.text, forked);
  });

  testWidgets('a stale failing run does not ask before saving', (tester) async {
    stubPage(
      error: const SourceScriptException(function: 'manga', message: 'boom'),
    );
    final edited = _code(body: 'const source = { v: 2 };');
    when(
      () => registry.save(any()),
    ).thenAnswer((_) async => _entry(SourceStatus.modified, code: edited));
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );
    await tapText(tester, 'Test');

    await tester.enterText(find.byKey(SourceEditorScreen.editorKey), edited);
    await pumpFrames(tester);
    await tester.tap(find.byTooltip('Save'));
    await pumpFrames(tester);

    expect(find.text('Test is failing. Save anyway?'), findsNothing);
    verify(() => registry.save(edited)).called(1);
  });

  testWidgets('save is disabled while a test runs', (tester) async {
    final gate = Completer<void>();
    stubPage(value: {'title': 'Solo'}, gate: gate);
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );
    await tester.enterText(
      find.byKey(SourceEditorScreen.editorKey),
      _code(body: 'const source = { v: 2 };'),
    );
    await pumpFrames(tester);

    await tapText(tester, 'Test');
    IconButton save() => tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.save),
        matching: find.byType(IconButton),
      ),
    );
    expect(save().onPressed, isNull);

    gate.complete();
    await pumpFrames(tester);
    expect(save().onPressed, isNotNull);
  });

  testWidgets('saving after a failing test asks for confirmation', (
    tester,
  ) async {
    stubPage(
      error: const SourceScriptException(function: 'manga', message: 'boom'),
    );
    final edited = _code(body: 'const source = { v: 2 };');
    when(
      () => registry.save(any()),
    ).thenAnswer((_) async => _entry(SourceStatus.modified, code: edited));
    await pumpScreen(
      tester,
      function: 'manga',
      url: 'https://asurascans.com/comics/a',
    );
    await tester.enterText(find.byKey(SourceEditorScreen.editorKey), edited);
    await pumpFrames(tester);
    await tapText(tester, 'Test');

    await tester.tap(find.byTooltip('Save'));
    await pumpFrames(tester);

    expect(find.text('Test is failing. Save anyway?'), findsOneWidget);
    verifyNever(() => registry.save(any()));

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Save'),
      ),
    );
    await pumpFrames(tester);

    verify(() => registry.save(edited)).called(1);
    expect(cubit!.state.savedCode, edited);
  });

  testWidgets('reset confirms, then restores the built-in script', (
    tester,
  ) async {
    final shippedCode = _code(body: 'const source = { shipped: true };');
    when(() => registry.reset('asura-scans')).thenAnswer((_) async {
      entries.add([
        _entry(
          SourceStatus.shipped,
          code: shippedCode,
          shippedCode: shippedCode,
        ),
      ]);
    });
    await pumpScreen(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await pumpFrames(tester);
    await tapText(tester, 'Reset to built-in');
    verifyNever(() => registry.reset(any()));
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Reset'),
      ),
    );
    await pumpFrames(tester);

    verify(() => registry.reset('asura-scans')).called(1);
    expect(editorField(tester).controller!.text, shippedCode);
  });

  testWidgets('update available offers to view the new version', (
    tester,
  ) async {
    final shippedCode = _code(body: 'const source = { newer: true };');
    entries.add([
      _entry(SourceStatus.updateAvailable, shippedCode: shippedCode),
    ]);
    await pumpScreen(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await pumpFrames(tester);
    await tapText(tester, 'View new version');

    expect(find.textContaining('newer: true'), findsOneWidget);
  });

  testWidgets('a built-in source has no reset action', (tester) async {
    entries.add([_entry(SourceStatus.shipped)]);
    await pumpScreen(tester);

    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('an unknown id shows an error state', (tester) async {
    await pumpScreen(tester, id: 'gone');

    expect(find.text('Source not found'), findsOneWidget);
    expect(find.byKey(SourceEditorScreen.editorKey), findsNothing);
  });
}
