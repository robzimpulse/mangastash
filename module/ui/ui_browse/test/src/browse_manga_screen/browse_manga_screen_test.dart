// Widget tests for BrowseMangaScreen's search-field toggle (issue #128):
// opening the search field must only focus it — it must NOT re-init the
// browse query (which wipes an active title filter and refetches). Closing
// the field resets the query to unfiltered browse. Cubit behavior is
// covered in browse_manga_screen_cubit_test.dart; this file verifies the
// screen wiring.
//
// Run with: fvm flutter test test/src/browse_manga_screen/browse_manga_screen_test.dart
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_cubit.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_state.dart';

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
    final getTagsUseCase = MockGetTagsUseCase();
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

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: BrowseMangaScreen(imagesCacheManager: _NullCacheManager()),
        ),
      ),
    );
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
}
