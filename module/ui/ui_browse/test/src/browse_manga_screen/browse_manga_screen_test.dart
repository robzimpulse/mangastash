// Widget tests for BrowseMangaScreen's search-field toggle (issue #128):
// opening the search field must only focus it — it must NOT re-init the
// browse query (which wipes an active title filter and refetches). Closing
// the field resets the query to unfiltered browse. Cubit behavior is
// covered in browse_manga_screen_cubit_test.dart; this file verifies the
// screen wiring. Also covers the "Fix source" action offered next to a
// scripted-source parse failure (issue #115).
//
// Run with: fvm flutter test test/src/browse_manga_screen/browse_manga_screen_test.dart
import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_cubit.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_state.dart';
import 'package:ui_common/ui_common.dart';

import '../../mock/mock.dart';

/// [ImagesCacheManager] stand-in that never touches the real cache; the grid
/// renders no items in these tests, so no member is invoked.
class _NullCacheManager extends Mock implements ImagesCacheManager {}

/// Pumps [frames] of 200ms each. ScaffoldScreen contains an always-animating
/// shimmer, so pumpAndSettle never settles (see CLAUDE.md known blockers).
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  late MockSearchMangaUseCase searchMangaUseCase;
  late MockGetTagsUseCase getTagsUseCase;
  late BrowseMangaScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(MangaDexSourceExternal());
    registerFallbackValue(
      const SourceSearchMangaParameter(
        source: '',
        parameter: SearchMangaParameter(),
      ),
    );
  });

  setUp(() {
    searchMangaUseCase = MockSearchMangaUseCase();
    getTagsUseCase = MockGetTagsUseCase();
    when(
      () => getTagsUseCase.execute(
        source: any(named: 'source'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => Error<List<Tag>>(Exception('stubbed off in test')));
    when(
      () => searchMangaUseCase.clear(parameter: any(named: 'parameter')),
    ).thenAnswer((_) async {});
    when(
      () => searchMangaUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(
      (_) async => Error<Pagination<Manga>>(Exception('stubbed off in test')),
    );

    cubit = BrowseMangaScreenCubit(
      initialState: BrowseMangaScreenState(source: MangaDexSourceExternal()),
      searchMangaUseCase: searchMangaUseCase,
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getTagsUseCase: getTagsUseCase,
      recrawlUseCase: MockRecrawlUseCase(),
    );
    addTearDown(cubit.close);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    ValueSetter<FixSourceTarget>? onTapFixSource,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: BrowseMangaScreen(
            imagesCacheManager: _NullCacheManager(),
            onTapFixSource: onTapFixSource,
          ),
        ),
      ),
    );
  }

  /// Makes the search fail with [error]; tags load fine so their (stubbed
  /// off) failure cannot overwrite it in the state.
  void stubSearchError(Exception error) {
    when(
      () => getTagsUseCase.execute(
        source: any(named: 'source'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => Success<List<Tag>>(const []));
    when(
      () => searchMangaUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => Error<Pagination<Manga>>(error));
  }

  testWidgets('opening the search field does not refetch the query (#128)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);

    verifyNever(
      () => searchMangaUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    );
  });

  testWidgets('closing the search field resets to unfiltered browse (#128)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);
    await tester.tap(find.byIcon(Icons.close));
    await pumpFrames(tester);

    final verification = verify(
      () => searchMangaUseCase.execute(
        parameter: captureAny(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    );
    verification.called(1);
    final captured = verification.captured[0] as SourceSearchMangaParameter;
    expect(captured.parameter.title, '');
  });

  // Review on #174: closing resets the query to `title: ''` but the
  // controller kept the old text, so submit -> close -> reopen showed a
  // populated field over unfiltered results. The field must be cleared
  // alongside the reset so it agrees with the active query.
  testWidgets(
    'reopening the search field after close shows an empty field (#174)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);
    await tester.enterText(find.byType(TextField), 'solo leveling');
    await pumpFrames(tester);
    await tester.tap(find.byIcon(Icons.close));
    await pumpFrames(tester);
    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('solo leveling'), findsNothing);
  });

  group('Fix source (#115)', () {
    testWidgets('a scripted-source parse error offers it and reports the '
        'target', (tester) async {
      stubSearchError(
        FailedParsingHtmlException(
          'https://example.com/browse',
          source: 'Manga Katana',
          parser: 'search',
        ),
      );
      FixSourceTarget? tapped;
      await pumpScreen(tester, onTapFixSource: (e) => tapped = e);
      unawaited(cubit.init());
      await pumpFrames(tester);

      expect(find.text('Fix source'), findsOneWidget);
      await tester.tap(find.text('Fix source'));
      await pumpFrames(tester);

      expect(
        tapped,
        const FixSourceTarget(
          sourceName: 'Manga Katana',
          function: 'search',
          url: 'https://example.com/browse',
        ),
      );
    });

    testWidgets('a script runtime error offers it too', (tester) async {
      stubSearchError(
        const SourceScriptException(
          function: 'search',
          message: 'boom',
          source: 'Asura Scans',
          url: 'https://example.com/browse',
        ),
      );
      await pumpScreen(tester, onTapFixSource: (_) {});
      unawaited(cubit.init());
      await pumpFrames(tester);

      expect(find.text('Fix source'), findsOneWidget);
    });

    testWidgets('an unrelated error does not offer it', (tester) async {
      await pumpScreen(tester, onTapFixSource: (_) {});
      unawaited(cubit.init());
      await pumpFrames(tester);

      expect(find.text('Fix source'), findsNothing);
    });

    testWidgets('is hidden when the screen has no handler', (tester) async {
      stubSearchError(
        FailedParsingHtmlException('u', source: 'S', parser: 'search'),
      );
      await pumpScreen(tester);
      unawaited(cubit.init());
      await pumpFrames(tester);

      expect(find.text('Fix source'), findsNothing);
    });
  });
}
