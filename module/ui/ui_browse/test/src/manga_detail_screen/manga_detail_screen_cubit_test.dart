// Tests for MangaDetailScreenCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
//
// Run with: fvm flutter test test/src/manga_detail_screen/manga_detail_screen_cubit_test.dart
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/sources/asura_scan_source_external.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/manga_detail_screen/manga_detail_screen_cubit.dart';
import 'package:ui_browse/src/manga_detail_screen/manga_detail_screen_state.dart';

import '../../mock/mock.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(MangaDexSourceExternal());
    registerFallbackValue(
      const SourceSearchMangaParameter(source: '', parameter: SearchMangaParameter()),
    );
    registerFallbackValue(
      SourceSearchChapterParameter(
        source: '',
        parameter: const SearchChapterParameter(),
        mangaId: '',
      ),
    );
  });

  test('recrawl passes no scripts for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
      ),
    ).thenAnswer((_) async {});

    final cubit = MangaDetailScreenCubit(
      initialState: MangaDetailScreenState(source: MangaDexSourceExternal()),
      getMangaUseCase: MockGetMangaUseCase(),
      searchMangaUseCase: searchMangaUseCase,
      searchChapterUseCase: MockSearchChapterUseCase(),
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getAllChapterUseCase: MockGetAllChapterUseCase(),
      recrawlUseCase: recrawlUseCase,
      listenDownloadedChapterUseCase: MockListenDownloadedChapterUseCase(),
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

  test('recrawl passes the source scripts through for a scraped source', () async {
    final source = AsuraScanSourceExternal();
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
      ),
    ).thenAnswer((_) async {});

    final cubit = MangaDetailScreenCubit(
      initialState: MangaDetailScreenState(source: source),
      getMangaUseCase: MockGetMangaUseCase(),
      searchMangaUseCase: searchMangaUseCase,
      searchChapterUseCase: MockSearchChapterUseCase(),
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getAllChapterUseCase: MockGetAllChapterUseCase(),
      recrawlUseCase: recrawlUseCase,
      listenDownloadedChapterUseCase: MockListenDownloadedChapterUseCase(),
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
        scripts: captureAny(named: 'scripts'),
      ),
    );
    verification.called(1);
    expect(
      verification.captured[2] as List<String>,
      source.getMangaUseCase.scripts,
    );
  });

  group('MangaDetailScreenCubit.init (issue #122 hardening)', () {
    test(
      'init resets every loading flag and emits errorManga when the manga fetch throws',
      () async {
        final getMangaUseCase = MockGetMangaUseCase();
        final searchMangaUseCase = MockSearchMangaUseCase();
        final searchChapterUseCase = MockSearchChapterUseCase();
        // The constructor subscribes to the downloaded-chapter stream as
        // soon as the state carries a mangaId.
        final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
        when(
          () => listenDownloadedChapterUseCase.execute(
            mangaId: any(named: 'mangaId'),
          ),
        ).thenAnswer((_) => const Stream.empty());
        // Chapters and similar manga fail softly (Error results) so only the
        // manga fetch throws.
        when(
          () => searchChapterUseCase.execute(
            parameter: any(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).thenAnswer(
          (_) async => Error<Pagination<Chapter>>(
            Exception('stubbed off in test'),
          ),
        );
        when(
          () => searchMangaUseCase.execute(
            parameter: any(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).thenAnswer(
          (_) async => Error<Pagination<Manga>>(
            Exception('stubbed off in test'),
          ),
        );
        when(
          () => getMangaUseCase.execute(
            mangaId: any(named: 'mangaId'),
            source: any(named: 'source'),
            useCache: any(named: 'useCache'),
          ),
        ).thenThrow(Exception('fetch failed'));

        final cubit = MangaDetailScreenCubit(
          initialState: MangaDetailScreenState(
            source: MangaDexSourceExternal(),
            mangaId: 'm-1',
          ),
          getMangaUseCase: getMangaUseCase,
          searchMangaUseCase: searchMangaUseCase,
          searchChapterUseCase: searchChapterUseCase,
          addToLibraryUseCase: MockAddToLibraryUseCase(),
          removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
          listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
          listenPrefetchUseCase: mockListenPrefetchUseCase(),
          prefetchChapterUseCase: MockPrefetchChapterUseCase(),
          listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
          listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
          getAllChapterUseCase: MockGetAllChapterUseCase(),
          recrawlUseCase: MockRecrawlUseCase(),
          listenDownloadedChapterUseCase: listenDownloadedChapterUseCase,
        );
        addTearDown(cubit.close);

        await cubit.init();

        expect(cubit.state.isLoadingManga, isFalse);
        expect(cubit.state.errorManga, isA<Exception>());
        // The chapter and similar-manga phases still ran and finished.
        expect(cubit.state.isLoadingChapters, isFalse);
        expect(cubit.state.isLoadingSimilarManga, isFalse);
      },
    );
  });
}
