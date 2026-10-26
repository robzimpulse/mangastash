/// Widget tests for SourceListScreen (issue #115, spec §8): the rows (MangaDex
/// toggle-only plus one row per script entry with a status chip), the delete
/// and reset confirmations, and the clipboard-driven "Add source" flow with
/// its trust dialog and parse-error snackbar.
///
/// Run: `cd module/ui/ui_more && fvm flutter test test/src/source_list_screen`.
/// ScaffoldScreen shimmers forever, so interactions are followed by
/// [pumpFrames] instead of pumpAndSettle (see CLAUDE.md).
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_more/src/source_list_screen/source_list_screen.dart';
import 'package:ui_more/src/source_list_screen/source_list_screen_cubit.dart';

class _MockSourceRegistry extends Mock implements SourceRegistry {}

class _MockListenSourcesUseCase extends Mock implements ListenSourcesUseCase {}

class _MockUpdateSourcesUseCase extends Mock implements UpdateSourcesUseCase {}

class _MockSource extends Mock implements SourceExternal {}

String _code(String id, String name, {List<String>? hosts, int version = 1}) {
  final hostList = (hosts ?? ['$id.com']).map((e) => '"$e"').join(', ');
  return '// ==MangaStashSource==\n'
      '// {"id": "$id", "name": "$name", "baseUrl": "https://$id.com", '
      '"version": $version, "contract": 1, "hosts": [$hostList]}\n'
      '// ==/MangaStashSource==\n'
      'function searchUrl() {}\n';
}

SourceEntry _entry(
  String id,
  String name,
  SourceStatus status, {
  String? code,
}) {
  final script = SourceScript.parse(code ?? _code(id, name));
  return SourceEntry(
    script: script,
    status: status,
    shipped: status == SourceStatus.custom ? null : script,
  );
}

_MockSource _source(String name, {bool builtIn = false}) {
  final source = _MockSource();
  when(() => source.name).thenReturn(name);
  when(() => source.builtIn).thenReturn(builtIn);
  return source;
}

void main() {
  late _MockSourceRegistry registry;
  late _MockListenSourcesUseCase listenSources;
  late _MockUpdateSourcesUseCase updateSources;
  late BehaviorSubject<List<SourceEntry>> entries;
  late BehaviorSubject<List<SourceExternal>> enabled;
  late Map<String, _MockSource> sourcesByName;
  late SourceListScreenCubit cubit;
  late String? clipboardText;
  late List<String> edited;

  final shipped = [
    _entry('asura-scans', 'Asura Scans', SourceStatus.shipped),
    _entry('weeb-central', 'Weeb Central', SourceStatus.shipped),
    _entry('manga-katana', 'Manga Katana', SourceStatus.shipped),
    _entry('manhua-plus', 'Manhua Plus', SourceStatus.shipped),
  ];

  setUpAll(() {
    registerFallbackValue(<SourceExternal>[]);
  });

  setUp(() {
    registry = _MockSourceRegistry();
    listenSources = _MockListenSourcesUseCase();
    updateSources = _MockUpdateSourcesUseCase();
    entries = BehaviorSubject.seeded(shipped);
    sourcesByName = {
      'Manga Dex': _source('Manga Dex', builtIn: true),
      for (final name in [
        'Asura Scans',
        'Weeb Central',
        'Manga Katana',
        'Manhua Plus',
        'My Site',
        'New Site',
      ])
        name: _source(name),
    };
    enabled = BehaviorSubject.seeded([
      for (final name in ['Manga Dex', 'Asura Scans', 'Weeb Central'])
        sourcesByName[name]!,
    ]);
    when(() => registry.entries).thenAnswer((_) => entries.stream);
    when(() => registry.values).thenReturn(sourcesByName.values.toList());
    when(() => registry.fromName(any())).thenAnswer(
      (invocation) => sourcesByName[invocation.positionalArguments.first],
    );
    when(() => listenSources.sourceStateStream).thenAnswer((_) => enabled);
    when(
      () => updateSources.updateSources(sources: any(named: 'sources')),
    ).thenAnswer((_) async {});

    clipboardText = null;
    edited = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') {
            final text = clipboardText;
            return text == null ? null : <String, dynamic>{'text': text};
          }
          return null;
        });

    cubit = SourceListScreenCubit(
      registry: registry,
      listenSourcesUseCase: listenSources,
      updateSourcesUseCase: updateSources,
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    await cubit.close();
    await entries.close();
    await enabled.close();
  });

  Future<void> pumpFrames(WidgetTester tester, {int count = 4}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SourceListScreenCubit>.value(
          value: cubit,
          child: SourceListScreen(onTapEdit: edited.add),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  /// Adds the custom 'my-site' entry (enabled) to the registry streams.
  void withCustomEntry() {
    entries.add([
      ...shipped,
      _entry('my-site', 'My Site', SourceStatus.custom),
    ]);
    enabled.add([...enabled.value, sourcesByName['My Site']!]);
  }

  List<SourceExternal> capturedSources() {
    return verify(
          () => updateSources.updateSources(
            sources: captureAny(named: 'sources'),
          ),
        ).captured.single
        as List<SourceExternal>;
  }

  testWidgets('shows the 4 shipped entries and MangaDex', (tester) async {
    await pumpScreen(tester);

    for (final name in [
      'Manga Dex',
      'Asura Scans',
      'Weeb Central',
      'Manga Katana',
      'Manhua Plus',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.text('Built-in'), findsNWidgets(4));
    // Only enabled sources have their switch on.
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches, hasLength(5));
    expect(switches.where((e) => e.value), hasLength(3));
  });

  testWidgets('a modified entry shows the Modified chip', (tester) async {
    entries.add([
      _entry('asura-scans', 'Asura Scans', SourceStatus.modified),
      ...shipped.skip(1),
    ]);
    await pumpScreen(tester);

    expect(find.text('Modified'), findsOneWidget);
    expect(find.text('Built-in'), findsNWidgets(3));
  });

  testWidgets('tapping a row opens the editor with the source id', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Weeb Central'));
    await pumpFrames(tester);

    expect(edited, ['weeb-central']);
  });

  testWidgets('toggling a source persists the enabled names', (tester) async {
    await pumpScreen(tester);

    // Manga Katana is disabled; switch it on.
    await tester.tap(find.byType(Switch).at(3));
    await pumpFrames(tester);

    expect(capturedSources().map((e) => e.name), [
      'Manga Dex',
      'Asura Scans',
      'Weeb Central',
      'Manga Katana',
    ]);
  });

  testWidgets('delete confirms, then deletes and disables the source', (
    tester,
  ) async {
    when(() => registry.delete('my-site')).thenAnswer((_) async {});
    withCustomEntry();
    await pumpScreen(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await pumpFrames(tester);
    await tester.tap(find.text('Delete'));
    await pumpFrames(tester);

    expect(
      find.text(
        'Delete My Site? Its library, history and chapters are kept and come '
        'back if you add a source with the same name.',
      ),
      findsOneWidget,
    );
    verifyNever(() => registry.delete(any()));

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await pumpFrames(tester);

    verify(() => registry.delete('my-site')).called(1);
    expect(capturedSources().map((e) => e.name), [
      'Manga Dex',
      'Asura Scans',
      'Weeb Central',
    ]);
  });

  testWidgets('cancelling the delete dialog deletes nothing', (tester) async {
    withCustomEntry();
    await pumpScreen(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await pumpFrames(tester);
    await tester.tap(find.text('Delete'));
    await pumpFrames(tester);
    await tester.tap(find.text('Cancel'));
    await pumpFrames(tester);

    verifyNever(() => registry.delete(any()));
  });

  testWidgets('reset confirms, then restores the built-in script', (
    tester,
  ) async {
    when(() => registry.reset('asura-scans')).thenAnswer((_) async {});
    entries.add([
      _entry('asura-scans', 'Asura Scans', SourceStatus.modified),
      ...shipped.skip(1),
    ]);
    await pumpScreen(tester);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await pumpFrames(tester);
    await tester.tap(find.text('Reset to built-in'));
    await pumpFrames(tester);
    verifyNever(() => registry.reset(any()));

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Reset'),
      ),
    );
    await pumpFrames(tester);

    verify(() => registry.reset('asura-scans')).called(1);
  });

  testWidgets('add source shows hosts and trust copy, then saves and enables', (
    tester,
  ) async {
    final code = _code(
      'new-site',
      'New Site',
      hosts: ['new-site.com', 'cdn.new-site.net'],
    );
    clipboardText = 'Here you go:\n```js\n$code```\nEnjoy!';
    when(() => registry.classify(any())).thenReturn(const NewSource());
    when(() => registry.save(any())).thenAnswer(
      (_) async => _entry('new-site', 'New Site', SourceStatus.custom),
    );
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add source'));
    await pumpFrames(tester);

    expect(find.text('New Site'), findsOneWidget);
    expect(find.text('new-site.com'), findsOneWidget);
    expect(find.text('cdn.new-site.net'), findsOneWidget);
    // Declared, not enforced: hosts is self-declared header text the runtime
    // does not police (review on #194).
    expect(find.text('Declared hosts (not enforced):'), findsOneWidget);
    expect(
      find.textContaining('can contact any website'),
      findsOneWidget,
    );
    expect(find.textContaining("site's cookies"), findsOneWidget);
    expect(
      find.text(
        "Scripts run inside the site's page and can contact any website — "
        "they run with this app's network identity and the site's cookies, so "
        'they can send data anywhere. Only add scripts you trust.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Replace'), findsNothing);
    verifyNever(() => registry.save(any()));

    await tester.tap(find.text('Add and enable'));
    await pumpFrames(tester);

    verify(() => registry.save(code.trim())).called(1);
    expect(capturedSources().map((e) => e.name), [
      'Manga Dex',
      'Asura Scans',
      'Weeb Central',
      'New Site',
    ]);
  });

  testWidgets('add source of an existing id asks to replace it', (
    tester,
  ) async {
    final code = _code('asura-scans', 'Asura Scans', version: 2);
    clipboardText = code;
    when(
      () => registry.classify(any()),
    ).thenReturn(ReplacesSource(shipped.first));
    when(() => registry.save(any())).thenAnswer((_) async => shipped.first);
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add source'));
    await pumpFrames(tester);

    expect(find.text('Replace Asura Scans?'), findsOneWidget);
    await tester.tap(find.text('Replace'));
    await pumpFrames(tester);

    verify(() => registry.save(code.trim())).called(1);
  });

  testWidgets('add source with an invalid script shows the parse error', (
    tester,
  ) async {
    clipboardText = 'this is not a script';
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add source'));
    await pumpFrames(tester);

    expect(
      find.text('Script must start with "// ==MangaStashSource==" header'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(() => registry.save(any()));
  });

  testWidgets('a rejected save shows the rejection message', (tester) async {
    clipboardText = _code('new-site', 'New Site');
    when(() => registry.classify(any())).thenReturn(const NewSource());
    when(() => registry.save(any())).thenAnswer(
      (_) async =>
          throw const SourceScriptRejected(
            'Name "New Site" is already used by another source',
          ),
    );
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add source'));
    await pumpFrames(tester);
    await tester.tap(find.text('Add and enable'));
    await pumpFrames(tester);

    expect(
      find.text('Name "New Site" is already used by another source'),
      findsOneWidget,
    );
  });

  testWidgets('an empty clipboard shows a hint', (tester) async {
    clipboardText = null;
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Add source'));
    await pumpFrames(tester);

    expect(find.text('Clipboard is empty'), findsOneWidget);
  });
}
