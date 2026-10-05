// Tests for MangaDetailScreenCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
//
// Run with: fvm flutter test test/src/manga_detail_screen/manga_detail_screen_cubit_test.dart
import 'dart:async';

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
    registerFallbackValue(const Manga());
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
      'nextChapter resets the paging flag when the fetch throws (review on #160)',
      () async {
        final searchChapterUseCase = MockSearchChapterUseCase();
        when(
          () => searchChapterUseCase.execute(
            parameter: any(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).thenThrow(Exception('fetch failed'));
        // The constructor subscribes to the downloaded-chapter stream as
        // soon as the state carries a mangaId.
        final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
        when(
          () => listenDownloadedChapterUseCase.execute(
            mangaId: any(named: 'mangaId'),
          ),
        ).thenAnswer((_) => const Stream.empty());

        final cubit = MangaDetailScreenCubit(
          initialState: MangaDetailScreenState(
            source: MangaDexSourceExternal(),
            mangaId: 'm-1',
          ),
          getMangaUseCase: MockGetMangaUseCase(),
          searchMangaUseCase: MockSearchMangaUseCase(),
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

        cubit.emit(cubit.state.copyWith(hasNextPageChapter: true));

        await cubit.nextChapter();

        expect(cubit.state.isPagingNextPageChapter, isFalse);
        expect(cubit.state.errorChapters, isA<Exception>());
      },
    );

    test(
      'nextSimilarManga resets the paging flag when the fetch throws (review on #160)',
      () async {
        final searchMangaUseCase = MockSearchMangaUseCase();
        when(
          () => searchMangaUseCase.execute(
            parameter: any(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).thenThrow(Exception('fetch failed'));
        // The constructor subscribes to the downloaded-chapter stream as
        // soon as the state carries a mangaId.
        final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
        when(
          () => listenDownloadedChapterUseCase.execute(
            mangaId: any(named: 'mangaId'),
          ),
        ).thenAnswer((_) => const Stream.empty());

        final cubit = MangaDetailScreenCubit(
          initialState: MangaDetailScreenState(
            source: MangaDexSourceExternal(),
            mangaId: 'm-1',
          ),
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
          recrawlUseCase: MockRecrawlUseCase(),
          listenDownloadedChapterUseCase: listenDownloadedChapterUseCase,
        );
        addTearDown(cubit.close);

        cubit.emit(
          cubit.state.copyWith(
            hasNextPageSimilarManga: true,
            // _fetchSimilarManga early-returns without a parameter.
            similarMangaParameter: const SearchMangaParameter(page: 1),
          ),
        );

        await cubit.nextSimilarManga();

        expect(cubit.state.isPagingNextPageSimilarManga, isFalse);
        expect(cubit.state.errorSimilarManga, isA<Exception>());
      },
    );

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

  // Issue #127: mutating actions on the detail screen need in-flight
  // guards — the favorite toggle must no-op while the same manga's toggle
  // is pending, and prefetch-all must not re-enter across its internal
  // await nor re-enqueue chapters already sitting in the job queue.
  group('in-flight guards (#127)', () {
    late MockAddToLibraryUseCase addToLibraryUseCase;
    late MockGetAllChapterUseCase getAllChapterUseCase;
    late MockPrefetchChapterUseCase prefetchChapterUseCase;
    late MangaDetailScreenCubit cubit;

    MangaDetailScreenCubit buildCubit({MangaDetailScreenState? initialState}) {
      return MangaDetailScreenCubit(
        initialState:
            initialState ??
            MangaDetailScreenState(
              manga: const Manga(id: 'm-1', source: 'Manga Dex'),
            ),
        getMangaUseCase: MockGetMangaUseCase(),
        searchMangaUseCase: MockSearchMangaUseCase(),
        searchChapterUseCase: MockSearchChapterUseCase(),
        addToLibraryUseCase: addToLibraryUseCase,
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        listenPrefetchUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: prefetchChapterUseCase,
        listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
        listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
        getAllChapterUseCase: getAllChapterUseCase,
        recrawlUseCase: MockRecrawlUseCase(),
        listenDownloadedChapterUseCase: MockListenDownloadedChapterUseCase(),
      );
    }

    setUp(() {
      addToLibraryUseCase = MockAddToLibraryUseCase();
      getAllChapterUseCase = MockGetAllChapterUseCase();
      prefetchChapterUseCase = MockPrefetchChapterUseCase();
    });

    test('a second favorite tap while the first is pending is ignored', () async {
      cubit = buildCubit();
      addTearDown(cubit.close);
      final gate = Completer<Result<bool>>();
      when(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      ).thenAnswer((_) => gate.future);

      const manga = Manga(id: 'm-1', source: 'Manga Dex');
      final first = cubit.addToLibrary(manga: manga);
      await pumpEventQueue();
      final second = cubit.addToLibrary(manga: manga);
      await pumpEventQueue();

      verify(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      ).called(1);

      gate.complete(Success<bool>(true));
      await Future.wait([first, second]);
    });

    test('prefetch is ignored while a prefetch-all is already running', () async {
      cubit = buildCubit();
      addTearDown(cubit.close);
      final gate = Completer<List<Chapter>>();
      when(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenAnswer((_) => gate.future);

      final first = cubit.prefetch();
      await pumpEventQueue();
      expect(cubit.state.isPrefetchingAll, isTrue);
      final second = cubit.prefetch();
      await pumpEventQueue();

      verify(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).called(1);

      gate.complete([const Chapter(id: 'c-1')]);
      await Future.wait([first, second]);
      expect(cubit.state.isPrefetchingAll, isFalse);
    });

    test('prefetch skips chapters already queued in the job queue', () async {
      cubit = buildCubit(
        initialState: MangaDetailScreenState(
          manga: const Manga(id: 'm-1', source: 'Manga Dex'),
          prefetchedChapterIds: const {'c-1'},
        ),
      );
      addTearDown(cubit.close);
      when(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenAnswer(
        (_) async => const [Chapter(id: 'c-1'), Chapter(id: 'c-2')],
      );

      await cubit.prefetch();

      final verification = verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: captureAny(named: 'chapterId'),
        ),
      );
      verification.called(1);
      expect(verification.captured, ['c-2']);
      expect(cubit.state.isPrefetchingAll, isFalse);
    });
  });
}
