// Tests for MangaDetailScreenCubit, grouped by the fix that introduced each
// case:
//
//   - recrawl — the built-in MangaDex source has no scraping use cases (getters
//     throw UnimplementedError by design), so recrawl must pass an empty scripts
//     list instead of crashing; plus #130, recrawl must await the re-crawl
//     before the refetches that read the html cache it writes.
//   - init (#122) — loading/paging flags must never be stranded by a throw.
//   - in-flight guards (#127) — repeat taps on addToLibrary and prefetch are
//     no-ops, and chapters already in the job queue are not re-enqueued.
//   - download (#119) — All/Unread scoping, the enqueued-count contract the
//     screen's snackbars depend on, the synchronous staging of queued ids, the
//     isPrefetchingAll lane, and downloadManga / downloadChapter.
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

    // Issue #130: recrawl fired the use case without awaiting it before
    // refreshing, so the refresh could serve the old cached page while the
    // headless browser was still re-crawling.
    test('recrawl awaits the re-crawl before refreshing (#130)', () async {
      final recrawlUseCase = MockRecrawlUseCase();
      final getMangaUseCase = MockGetMangaUseCase();
      final searchChapterUseCase = MockSearchChapterUseCase();
      final searchMangaUseCase = MockSearchMangaUseCase();
      final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
      when(
        () => listenDownloadedChapterUseCase.execute(
          mangaId: any(named: 'mangaId'),
        ),
      ).thenAnswer((_) => const Stream.empty());
      final gate = Completer<void>();
      when(
        () => recrawlUseCase.execute(
          context: any(named: 'context'),
          url: any(named: 'url'),
          scripts: any(named: 'scripts'),
        ),
      ).thenAnswer((_) => gate.future);
      when(
        () => getMangaUseCase.execute(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Error<Manga>(Exception('stubbed off in test')));
      when(
        () => searchChapterUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer(
        (_) async => Error<Pagination<Chapter>>(Exception('stubbed off in test')),
      );
      when(
        () => searchMangaUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer(
        (_) async => Error<Pagination<Manga>>(Exception('stubbed off in test')),
      );
      when(
        () => searchChapterUseCase.clear(parameter: any(named: 'parameter')),
      ).thenAnswer((_) async {});
      when(
        () => searchMangaUseCase.clear(parameter: any(named: 'parameter')),
      ).thenAnswer((_) async {});

      cubit = MangaDetailScreenCubit(
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
        recrawlUseCase: recrawlUseCase,
        listenDownloadedChapterUseCase: listenDownloadedChapterUseCase,
      );
      addTearDown(cubit.close);

      cubit.recrawl(
        context: _FakeBuildContext(),
        url: 'https://scraped.example.com/comics/solo',
      );
      await pumpEventQueue();

      // While the headless browser is still re-crawling, the refresh must
      // not have started — it would read the old cached page.
      verifyNever(
        () => getMangaUseCase.execute(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          useCache: any(named: 'useCache'),
        ),
      );

      gate.complete();
      await pumpEventQueue();

      verify(
        () => getMangaUseCase.execute(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          useCache: any(named: 'useCache'),
        ),
      ).called(1);
    });
  });

  // Issue #119: download enqueues chapters onto the prefetch pipeline. Two
  // contracts matter to the screen that calls it — the returned count is what
  // separates "queued work" from "nothing to queue", and a second tap must not
  // re-enqueue chapters whose ids are still travelling back through the async
  // chapterIdsStream hop.
  group('download (#119)', () {
    late MockGetAllChapterUseCase getAllChapterUseCase;
    late MockPrefetchChapterUseCase prefetchChapterUseCase;
    late MangaDetailScreenCubit downloadCubit;

    /// Builds the subject, publishes it as [downloadCubit], and registers its
    /// own teardown. Tests assign `downloadCubit = buildCubit(...)` so a custom
    /// initialState is one argument away.
    ///
    /// The default state carries the identity `MangaDetailScreen.create` puts
    /// in from the route params — mangaId AND source — because download()
    /// resolves its target from those two, not from the loaded record (see the
    /// guard tests below).
    MangaDetailScreenCubit buildCubit({MangaDetailScreenState? initialState}) {
      // The constructor subscribes to the downloaded-chapter stream as soon as
      // the state carries a mangaId; unstubbed, the mock returns null.
      final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
      when(
        () => listenDownloadedChapterUseCase.execute(
          mangaId: any(named: 'mangaId'),
        ),
      ).thenAnswer((_) => const Stream.empty());
      downloadCubit = MangaDetailScreenCubit(
        initialState:
            initialState ??
            MangaDetailScreenState(
              mangaId: 'm-1',
              manga: const Manga(id: 'm-1', source: 'Manga Dex'),
              source: MangaDexSourceExternal(),
            ),
        getMangaUseCase: MockGetMangaUseCase(),
        searchMangaUseCase: MockSearchMangaUseCase(),
        searchChapterUseCase: MockSearchChapterUseCase(),
        addToLibraryUseCase: MockAddToLibraryUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        listenPrefetchUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: prefetchChapterUseCase,
        listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
        listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
        getAllChapterUseCase: getAllChapterUseCase,
        recrawlUseCase: MockRecrawlUseCase(),
        listenDownloadedChapterUseCase: listenDownloadedChapterUseCase,
      );
      // The constructor registers four stream subscriptions plus, when the
      // state carries a mangaId, a fifth for the downloaded-chapter listener —
      // close() is what cancels them, so an unclosed cubit leaks every one.
      addTearDown(downloadCubit.close);
      return downloadCubit;
    }

    setUp(() {
      getAllChapterUseCase = MockGetAllChapterUseCase();
      prefetchChapterUseCase = MockPrefetchChapterUseCase();
    });

    void stubChapters(List<Chapter> chapters) {
      when(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenAnswer((_) async => chapters);
    }

    test('download all enqueues one job per unqueued chapter', () async {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          manga: const Manga(id: 'm-1', source: 'Manga Dex'),
          source: MangaDexSourceExternal(),
          prefetchedChapterIds: const {'a'},
        ),
      );
      stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

      final enqueued = await downloadCubit.download(
        option: DownloadOption.all,
      );

      expect(enqueued, 1);
      verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: 'm-1',
          source: any(named: 'source'),
          chapterId: 'b',
        ),
      ).called(1);
      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: 'a',
        ),
      );
      expect(downloadCubit.state.isPrefetchingAll, isFalse);
    });

    test('download unread with everything read enqueues nothing', () async {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          manga: const Manga(id: 'm-1', source: 'Manga Dex'),
          source: MangaDexSourceExternal(),
          histories: const {'a': Chapter(id: 'a')},
        ),
      );
      stubChapters(const [Chapter(id: 'a')]);

      final enqueued = await downloadCubit.download(
        option: DownloadOption.unread,
      );

      expect(enqueued, 0);
      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
      expect(downloadCubit.state.isPrefetchingAll, isFalse);
    });

    // The scope only differs for read chapters: "unread" must still queue an
    // unread one sitting next to a read sibling, otherwise the option would
    // degrade into "enqueue nothing".
    test('download unread still enqueues the chapters with no read history', () async {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          manga: const Manga(id: 'm-1', source: 'Manga Dex'),
          source: MangaDexSourceExternal(),
          histories: const {'a': Chapter(id: 'a')},
        ),
      );
      stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

      final enqueued = await downloadCubit.download(
        option: DownloadOption.unread,
      );

      expect(enqueued, 1);
      verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: 'b',
        ),
      ).called(1);
    });

    test('download returns 0 when every chapter is already queued', () async {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          manga: const Manga(id: 'm-1', source: 'Manga Dex'),
          source: MangaDexSourceExternal(),
          prefetchedChapterIds: const {'a', 'b'},
        ),
      );
      stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

      final enqueued = await downloadCubit.download(
        option: DownloadOption.all,
      );

      expect(enqueued, 0);
      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
    });

    // chapterIdsStream is stubbed to an empty stream — it never emits, so the
    // queued set can only come from download's own synchronous emit. Without
    // it the second tap reads the same state and re-enqueues every chapter.
    test('a double tap enqueues once', () async {
      downloadCubit = buildCubit();
      stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

      final first = await downloadCubit.download(option: DownloadOption.all);
      final second = await downloadCubit.download(option: DownloadOption.all);

      expect(first, 2);
      expect(second, 0);
      final verification = verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: captureAny(named: 'chapterId'),
        ),
      );
      verification.called(2);
      expect(verification.captured, ['a', 'b']);
      expect(downloadCubit.state.prefetchedChapterIds, {'a', 'b'});
    });

    test('download is ignored while another run is already in flight', () async {
      downloadCubit = buildCubit();
      final gate = Completer<List<Chapter>>();
      when(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenAnswer((_) => gate.future);

      final first = downloadCubit.download(option: DownloadOption.all);
      await pumpEventQueue();
      expect(downloadCubit.state.isPrefetchingAll, isTrue);
      final second = await downloadCubit.download(option: DownloadOption.all);

      expect(second, 0);
      verify(
        () => getAllChapterUseCase.execute(
          source: any(named: 'source'),
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).called(1);

      gate.complete(const [Chapter(id: 'a')]);
      expect(await first, 1);
      verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      ).called(1);
      expect(downloadCubit.state.isPrefetchingAll, isFalse);
    });

    // Identity comes from state.manga?.id ?? state.mangaId plus state.source
    // (same as _fetchManga), so a state carrying no id at all is the only
    // "no manga to download" case left. Task 5 turns the 0 into the snackbar,
    // so this guard is the whole "safe no-op" contract.
    test(
      'download returns 0 without fetching when the state carries no id',
      () async {
        downloadCubit = buildCubit(
          initialState: const MangaDetailScreenState(),
        );

        final enqueued = await downloadCubit.download(
          option: DownloadOption.all,
        );

        expect(enqueued, 0);
        verifyNever(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        );
        verifyNever(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: any(named: 'mangaId'),
            source: any(named: 'source'),
            chapterId: any(named: 'chapterId'),
          ),
        );
        expect(downloadCubit.state.isPrefetchingAll, isFalse);
      },
    );

    // state.source is resolved once at construction from the route param, so
    // "no source" is the whole guard — the manga's own `source` string is no
    // longer consulted and an unresolvable one cannot block the download.
    test(
      'download returns 0 without fetching when the state carries no source',
      () async {
        downloadCubit = buildCubit(
          initialState: const MangaDetailScreenState(
            mangaId: 'm-1',
            manga: Manga(id: 'm-1', source: 'Manga Dex'),
          ),
        );

        final enqueued = await downloadCubit.download(
          option: DownloadOption.all,
        );

        expect(enqueued, 0);
        verifyNever(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        );
        verifyNever(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: any(named: 'mangaId'),
            source: any(named: 'source'),
            chapterId: any(named: 'chapterId'),
          ),
        );
        expect(downloadCubit.state.isPrefetchingAll, isFalse);
      },
    );

    // GetMangaUseCase returning an Error is routine on scraped sources (issue
    // #119 review), and initChapter still populates the chapter list from the
    // route identity. Downloading from that state must enqueue, not report
    // "Nothing to download" for a chapter list the user can see.
    test('download enqueues when only the manga record failed to load', () async {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          source: MangaDexSourceExternal(),
        ),
      );
      stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

      final enqueued = await downloadCubit.download(
        option: DownloadOption.all,
      );

      expect(enqueued, 2);
      verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: 'm-1',
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      ).called(2);
    });

    test('downloadChapter enqueues when the manga record failed to load', () {
      downloadCubit = buildCubit(
        initialState: MangaDetailScreenState(
          mangaId: 'm-1',
          source: MangaDexSourceExternal(),
        ),
      );

      downloadCubit.downloadChapter(chapterId: 'a');

      verify(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: 'm-1',
          source: any(named: 'source'),
          chapterId: 'a',
        ),
      ).called(1);
      // The row still shows its spinner — this chapter belongs to the manga on
      // screen, so staging it is meaningful here (unlike downloadManga).
      expect(downloadCubit.state.prefetchedChapterIds, {'a'});
    });

    test('downloadChapter enqueues nothing without a source', () {
      downloadCubit = buildCubit(
        initialState: const MangaDetailScreenState(
          mangaId: 'm-1',
          manga: Manga(id: 'm-1', source: 'Manga Dex'),
        ),
      );

      downloadCubit.downloadChapter(chapterId: 'a');

      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
      expect(downloadCubit.state.prefetchedChapterIds, isEmpty);
    });

    // The similar-manga long press. It used to route through download(), which
    // reads state.manga — so it downloaded whatever was on screen while the
    // snackbar named the long-pressed title.
    group('downloadManga — the similar-manga long press (#119)', () {
      const similar = Manga(id: 's-1', source: 'Manga Dex');

      test('fetches and enqueues for the manga it was given, not the screen', () async {
        downloadCubit = buildCubit();
        stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

        final enqueued = await downloadCubit.downloadManga(manga: similar);

        expect(enqueued, 2);
        final fetched = verify(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: captureAny(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        );
        fetched.called(1);
        expect(fetched.captured, ['s-1']);
        verify(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: 's-1',
            source: any(named: 'source'),
            chapterId: any(named: 'chapterId'),
          ),
        ).called(2);
      });

      // prefetchedChapterIds renders the on-screen chapter rows' spinners;
      // this manga's ids would light up rows that belong to a different
      // series, so they are deliberately not staged.
      test('does not stage the enqueued ids into the screen chapter set', () async {
        downloadCubit = buildCubit();
        stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

        await downloadCubit.downloadManga(manga: similar);

        expect(downloadCubit.state.prefetchedChapterIds, isEmpty);
      });

      // Dedupe still applies — chapterIdsStream is a whole-job-table feed, so
      // this set covers the other manga's chapters too.
      test('skips chapters already sitting in the job queue', () async {
        downloadCubit = buildCubit(
          initialState: MangaDetailScreenState(
            mangaId: 'm-1',
            manga: const Manga(id: 'm-1', source: 'Manga Dex'),
            source: MangaDexSourceExternal(),
            prefetchedChapterIds: const {'a'},
          ),
        );
        stubChapters(const [Chapter(id: 'a'), Chapter(id: 'b')]);

        final enqueued = await downloadCubit.downloadManga(manga: similar);

        expect(enqueued, 1);
        verify(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: 's-1',
            source: any(named: 'source'),
            chapterId: 'b',
          ),
        ).called(1);
      });

      test('returns 0 without fetching for a manga with no id', () async {
        downloadCubit = buildCubit();

        final enqueued = await downloadCubit.downloadManga(
          manga: const Manga(source: 'Manga Dex'),
        );

        expect(enqueued, 0);
        verifyNever(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        );
        verifyNever(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: any(named: 'mangaId'),
            source: any(named: 'source'),
            chapterId: any(named: 'chapterId'),
          ),
        );
      });

      test('returns 0 without fetching when the state carries no source', () async {
        downloadCubit = buildCubit(
          initialState: const MangaDetailScreenState(
            mangaId: 'm-1',
            manga: Manga(id: 'm-1', source: 'Manga Dex'),
          ),
        );

        final enqueued = await downloadCubit.downloadManga(manga: similar);

        expect(enqueued, 0);
        verifyNever(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        );
      });

      // One bulk run at a time, shared with download()/prefetch() — otherwise
      // a second long press re-enqueues the same chapters.
      test('is ignored while another run is already in flight', () async {
        downloadCubit = buildCubit();
        final gate = Completer<List<Chapter>>();
        when(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        ).thenAnswer((_) => gate.future);

        final first = downloadCubit.downloadManga(manga: similar);
        await pumpEventQueue();
        expect(downloadCubit.state.isPrefetchingAll, isTrue);
        final second = await downloadCubit.downloadManga(manga: similar);

        expect(second, 0);

        gate.complete(const [Chapter(id: 'a')]);
        expect(await first, 1);
        expect(downloadCubit.state.isPrefetchingAll, isFalse);
      });
    });
  });
}
