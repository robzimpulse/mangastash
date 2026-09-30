// Tests for BrowseMangaScreenCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
//
// Run with: fvm flutter test test/src/browse_manga_screen/browse_manga_screen_cubit_test.dart
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_cubit.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_state.dart';

import '../../mock/mock.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(
      const SourceSearchMangaParameter(source: '', parameter: SearchMangaParameter()),
    );
    registerFallbackValue(MangaDexSourceExternal());
  });

  test('recrawl passes no scripts for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
    final getTagsUseCase = MockGetTagsUseCase();
    when(
      () => getTagsUseCase.execute(source: any(named: 'source'), useCache: any(named: 'useCache')),
    ).thenAnswer(
      (_) async => Error<List<Tag>>(Exception('stubbed off in test')),
    );
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
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
      ),
    ).thenAnswer((_) async {});

    final cubit = BrowseMangaScreenCubit(
      initialState: BrowseMangaScreenState(
        source: MangaDexSourceExternal(),
      ),
      searchMangaUseCase: searchMangaUseCase,
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getTagsUseCase: getTagsUseCase,
      recrawlUseCase: recrawlUseCase,
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://www.mangadex.org/');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
        scripts: captureAny(named: 'scripts'),
      ),
    );
    verification.called(1);
    expect(verification.captured[2] as List<String>, isEmpty);
  });
}
