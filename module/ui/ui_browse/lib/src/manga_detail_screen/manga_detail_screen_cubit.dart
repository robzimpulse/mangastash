import 'dart:async';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_screen_state.dart';

class MangaDetailScreenCubit extends Cubit<MangaDetailScreenState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _searchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final GetAllChapterUseCase _getAllChapterUseCase;
  final SearchMangaUseCase _searchMangaUseCase;
  final RecrawlUseCase _recrawlUseCase;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchMangaUseCase searchMangaUseCase,
    required SearchChapterUseCase searchChapterUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required GetAllChapterUseCase getAllChapterUseCase,
    required RecrawlUseCase recrawlUseCase,
    required ListenDownloadedChapterUseCase listenDownloadedChapterUseCase,
  }) : _getMangaUseCase = getMangaUseCase,
       _searchMangaUseCase = searchMangaUseCase,
       _searchChapterUseCase = searchChapterUseCase,
       _addToLibraryUseCase = addToLibraryUseCase,
       _removeFromLibraryUseCase = removeFromLibraryUseCase,
       _prefetchChapterUseCase = prefetchChapterUseCase,
       _getAllChapterUseCase = getAllChapterUseCase,
       _recrawlUseCase = recrawlUseCase,
       super(
         initialState.copyWith(
           chapterParameter: listenSearchParameterUseCase
               .searchParameterState
               .valueOrNull
               ?.let((e) => SearchChapterParameter.from(e)),
           similarMangaParameter:
               listenSearchParameterUseCase.searchParameterState.valueOrNull,
         ),
       ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryMangaIds.distinct().listen(
        _updateMangaLibrary,
      ),
    );
    addSubscription(
      listenPrefetchUseCase.chapterIdsStream.distinct().listen(
        _updatePrefetchChapterId,
      ),
    );
    addSubscription(
      listenPrefetchUseCase.mangaIdsStream.distinct().listen(
        _updatePrefetchMangaId,
      ),
    );
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen(
        _updateHistories,
      ),
    );
    state.mangaId.let((id) {
      addSubscription(
        listenDownloadedChapterUseCase
            .execute(mangaId: id)
            .distinct()
            .listen((_updateDownloadedChapterIds)),
      );
    });
  }

  void _updateDownloadedChapterIds(List<Chapter> chapters) {
    emit(
      state.copyWith(
        downloadedChapterIds: chapters.map((e) => e.id).nonNulls.toSet(),
      ),
    );
  }

  void _updateMangaLibrary(Set<String> libraryMangaIds) {
    emit(state.copyWith(libraryMangaIds: libraryMangaIds));
  }

  void _updatePrefetchChapterId(Set<String> prefetchedChapterIds) {
    emit(state.copyWith(prefetchedChapterIds: prefetchedChapterIds));
  }

  void _updatePrefetchMangaId(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  void _updateHistories(List<MangaChapter> histories) {
    final Map<String, Chapter> map = {};
    final data = histories.where((e) => e.manga?.id == state.mangaId);
    for (final history in data) {
      final value = history.chapter;
      final key = value?.id;
      if (key == null || value == null) continue;
      map[key] = value;
    }
    emit(state.copyWith(histories: map));
  }

  Future<void> init({bool useCache = true}) async {
    emit(state.copyWith(isLoadingManga: true, errorManga: () => null));
    try {
      await _fetchManga(useCache: useCache);
    } catch (e) {
      emit(state.copyWith(errorManga: () => _asException(e)));
    } finally {
      // A throw must never strand the loading flag (issue #122) — and the
      // remaining phases still run below.
      emit(state.copyWith(isLoadingManga: false));
    }

    await Future.wait([
      initChapter(refresh: !useCache),
      initSimilarManga(refresh: !useCache),
    ]);
  }

  Future<void> initChapter({
    ChapterConfig? config,
    bool refresh = false,
  }) async {
    final option = switch ((config ?? state.config).sortOption) {
      ChapterSortOptionEnum.chapterNumber => ChapterOrders.chapter,
      ChapterSortOptionEnum.uploadDate => ChapterOrders.readableAt,
    };

    final direction = switch ((config ?? state.config).sortOrder) {
      ChapterSortOrderEnum.asc => OrderDirections.ascending,
      ChapterSortOrderEnum.desc => OrderDirections.descending,
    };

    emit(
      state.copyWith(
        chapterParameter: state.chapterParameter.copyWith(
          offset: 0,
          page: 1,
          limit: 20,
          orders: {option: direction},
        ),
        chapters: [],
        isLoadingChapters: true,
        errorChapters: () => null,
        config: config,
      ),
    );

    if (refresh) await _clearChapterCache();

    try {
      await _fetchChapter(useCache: !refresh);
    } catch (e) {
      emit(state.copyWith(errorChapters: () => _asException(e)));
    } finally {
      emit(state.copyWith(isLoadingChapters: false));
    }
  }

  Future<void> initSimilarManga({refresh = false}) async {
    emit(
      state.copyWith(
        isLoadingSimilarManga: true,
        errorSimilarManga: () => null,
        similarMangaParameter: state.similarMangaParameter?.copyWith(
          offset: 0,
          page: 1,
          limit: 20,
          includedTags: [...?state.manga?.tags?.map((e) => e.id).nonNulls],
          excludedTags: [],
        ),
      ),
    );

    if (refresh) await _clearSimilarMangaCache();

    try {
      await _fetchSimilarManga(useCache: !refresh);
    } catch (e) {
      emit(state.copyWith(errorSimilarManga: () => _asException(e)));
    } finally {
      emit(state.copyWith(isLoadingSimilarManga: false));
    }
  }

  Future<void> _fetchManga({bool useCache = true}) async {
    final id = state.manga?.id ?? state.mangaId;
    final source = state.source;
    if (id == null || id.isEmpty || source == null) return;

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: source,
      useCache: useCache,
    );

    if (result is Success<Manga>) {
      emit(state.copyWith(manga: result.data));
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(errorManga: () => result.error));
    }

    emit(state.copyWith(isLoadingManga: false));
  }

  Future<void> _clearSimilarMangaCache() async {
    final source = state.source;
    final parameter = state.similarMangaParameter;

    if (source == null || parameter == null) return;

    await _searchMangaUseCase.clear(
      parameter: SourceSearchMangaParameter(
        source: source.name,
        parameter: parameter,
      ),
    );
  }

  Future<void> _fetchSimilarManga({bool useCache = true}) async {
    final source = state.source;
    final parameter = state.similarMangaParameter;

    if (source == null || parameter == null) return;

    final result = await _searchMangaUseCase.execute(
      parameter: SourceSearchMangaParameter(
        source: source.name,
        parameter: parameter,
      ),
      useCache: useCache,
    );

    if (result is Success<Pagination<Manga>>) {
      final offset = result.data.offset ?? 0;
      final page = result.data.page ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final mangas = result.data.data ?? [];
      final hasNextPage = result.data.hasNextPage;

      final allMangas = [...state.similarManga, ...mangas].distinct();

      emit(
        state.copyWith(
          similarManga: [...allMangas]
            ..removeWhere((e) => e.id == state.mangaId),
          hasNextPageSimilarManga: hasNextPage ?? allMangas.length < total,
          similarMangaParameter: parameter.copyWith(
            page: page + 1,
            offset: offset + limit,
            limit: limit,
          ),
          errorSimilarManga: () => null,
        ),
      );

      final mangasInLibrary = mangas.where(
        (e) => state.libraryMangaIds.contains(e.id),
      );
      for (final manga in mangasInLibrary) {
        final mangaId = manga.id;
        if (mangaId == null) continue;
        _prefetchChapterUseCase.prefetchChapters(
          mangaId: mangaId,
          source: source,
        );
      }
    }

    if (result is Error<Pagination<Manga>>) {
      emit(state.copyWith(errorSimilarManga: () => result.error));
    }
  }

  Future<void> _clearChapterCache() async {
    final id = state.manga?.id ?? state.mangaId;
    final source = state.source;
    if (id == null || id.isEmpty || source == null) return;

    await _searchChapterUseCase.clear(
      parameter: SourceSearchChapterParameter(
        source: source.name,
        parameter: state.chapterParameter,
        mangaId: id,
      ),
    );
  }

  Future<void> _fetchChapter({bool useCache = true}) async {
    final id = state.manga?.id ?? state.mangaId;
    final source = state.source;
    if (id == null || id.isEmpty || source == null) return;

    final result = await _searchChapterUseCase.execute(
      parameter: SourceSearchChapterParameter(
        source: source.name,
        parameter: state.chapterParameter,
        mangaId: id,
      ),
      useCache: useCache,
    );

    if (result is Success<Pagination<Chapter>>) {
      final offset = result.data.offset ?? 0;
      final page = result.data.page ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final chapters = result.data.data ?? [];
      final hasNextPage = result.data.hasNextPage;

      emit(
        state.copyWith(
          chapters: [...state.chapters, ...chapters].distinct(),
          hasNextPageChapter: hasNextPage,
          chapterParameter: state.chapterParameter.copyWith(
            page: page + 1,
            offset: offset + limit,
            limit: limit,
          ),
          totalChapter: total,
          errorChapters: () => null,
          sourceUrlChapter: () => result.data.sourceUrl,
        ),
      );
    }

    if (result is Error<Pagination<Chapter>>) {
      emit(state.copyWith(errorChapters: () => result.error));
    }
  }

  Future<void> nextChapter() async {
    if (state.isLoadingChapters) return;
    if (!state.hasNextPageChapter || state.isPagingNextPageChapter) return;
    emit(state.copyWith(isPagingNextPageChapter: true));
    // A throw must never strand the paging flag (review on #160) — the
    // #122 stall class in the chapter lane.
    try {
      await _fetchChapter();
    } catch (e) {
      emit(state.copyWith(errorChapters: () => _asException(e)));
    } finally {
      emit(state.copyWith(isPagingNextPageChapter: false));
    }
  }

  Future<void> nextSimilarManga() async {
    if (state.isLoadingSimilarManga) return;
    if (!state.hasNextPageSimilarManga || state.isPagingNextPageSimilarManga) {
      return;
    }
    emit(state.copyWith(isPagingNextPageSimilarManga: true));
    try {
      await _fetchSimilarManga();
    } catch (e) {
      emit(state.copyWith(errorSimilarManga: () => _asException(e)));
    } finally {
      emit(state.copyWith(isPagingNextPageSimilarManga: false));
    }
  }

  /// Toggles [manga] in/out of the library. No-ops while the same manga's
  /// toggle is already in flight (issue #127) — see
  /// BrowseMangaScreenCubit.addToLibrary for the race this prevents.
  Future<void> addToLibrary({required Manga manga}) async {
    final mangaId = manga.id;
    if (mangaId == null) return;
    if (state.pendingLibraryMangaIds.contains(mangaId)) return;

    emit(
      state.copyWith(
        pendingLibraryMangaIds: {...state.pendingLibraryMangaIds, mangaId},
      ),
    );
    try {
      if (state.libraryMangaIds.contains(mangaId)) {
        await _removeFromLibraryUseCase.execute(manga: manga);
      } else {
        await _addToLibraryUseCase.execute(manga: manga);
      }
    } finally {
      emit(
        state.copyWith(
          pendingLibraryMangaIds:
              {...state.pendingLibraryMangaIds}..remove(mangaId),
        ),
      );
    }
  }

  /// Enqueues every chapter of the manga for prefetching. Re-entry while a
  /// run is already awaiting the chapter list is ignored, and chapters
  /// already sitting in the job queue are skipped — re-tapping the button
  /// must not duplicate the workload (issue #127).
  Future<void> prefetch() async {
    if (state.isPrefetchingAll) return;
    final mangaId = state.manga?.id;
    final source = state.manga?.source?.let(Sources.fromName);
    if (mangaId == null || source == null) return;
    emit(state.copyWith(isPrefetchingAll: true));
    try {
      final chapters = await _getAllChapterUseCase.execute(
        source: source,
        mangaId: mangaId,
        parameter: state.chapterParameter.copyWith(offset: 0, page: 1, limit: 20),
      );
      for (final chapterId in chapters.map((e) => e.id).nonNulls) {
        if (state.prefetchedChapterIds.contains(chapterId)) continue;
        _prefetchChapterUseCase.prefetchChapter(
          mangaId: mangaId,
          source: source,
          chapterId: chapterId,
        );
      }
    } finally {
      emit(state.copyWith(isPrefetchingAll: false));
    }
  }

  /// Enqueues chapters of the manga on the prefetch pipeline, scoped by
  /// [option]: unread chapters only, or every chapter.
  ///
  /// Returns how many chapters were enqueued, so the caller can tell real
  /// queueing from "nothing left to download" — the screen shows the
  /// empty-target snackbar on 0 (#119).
  ///
  /// Reuses prefetch()'s #127 guards (one run at a time, chapters already in
  /// the job queue skipped) and additionally stages the enqueued ids into
  /// state *synchronously*: chapterIdsStream only refreshes
  /// [MangaDetailScreenState.prefetchedChapterIds] through an async hop, so
  /// without the synchronous emit a double tap re-enqueues everything before
  /// the stream emits.
  ///
  /// Unlike the bulk cubits' download, no prefetchManga job is enqueued: this
  /// screen already holds the manga, loaded and DB-synced by init(), and that
  /// job re-fetches (useCache: false) the very record on display. Do not
  /// "restore" the prefetchManga call here without a reason (#119).
  Future<int> download({required DownloadOption option}) async {
    if (state.isPrefetchingAll) return 0;
    final mangaId = state.manga?.id;
    final source = state.manga?.source?.let(Sources.fromName);
    if (mangaId == null || source == null) return 0;
    emit(state.copyWith(isPrefetchingAll: true));
    try {
      final chapters = await _getAllChapterUseCase.execute(
        source: source,
        mangaId: mangaId,
        parameter: state.chapterParameter.copyWith(offset: 0, page: 1, limit: 20),
      );
      final targets = resolveDownloadChapterIds(
        chapters: chapters,
        readChapterIds: state.histories.keys.toSet(),
        queuedChapterIds: state.prefetchedChapterIds,
        unreadOnly: option == DownloadOption.unread,
      );
      if (targets.isEmpty) return 0;
      final queued = {...state.prefetchedChapterIds};
      for (final chapterId in targets) {
        if (queued.contains(chapterId)) continue;
        _prefetchChapterUseCase.prefetchChapter(
          mangaId: mangaId,
          source: source,
          chapterId: chapterId,
        );
        queued.add(chapterId);
      }
      emit(state.copyWith(prefetchedChapterIds: queued));
      return targets.length;
    } finally {
      emit(state.copyWith(isPrefetchingAll: false));
    }
  }

  /// Enqueues a single chapter — the chapter row's long-press action (#119).
  /// Same path as the bulk [download] without the scoping step: one id, no
  /// resolver.
  ///
  /// Stages the id into [MangaDetailScreenState.prefetchedChapterIds]
  /// synchronously for the reason download() does — chapterIdsStream only
  /// refreshes that set through an async hop, so a repeat long-press would
  /// otherwise enqueue a duplicate job. The chapter row renders its spinner
  /// from that same set (manga_detail_screen.dart passes
  /// isPrefetching: prefetchedChapterIds.contains(id)), so the user sees the
  /// tap land and the already-queued long-press above is a no-op.
  void downloadChapter({required String chapterId}) {
    final mangaId = state.manga?.id;
    final source = state.manga?.source?.let(Sources.fromName);
    if (mangaId == null || source == null) return;
    if (state.prefetchedChapterIds.contains(chapterId)) return;
    _prefetchChapterUseCase.prefetchChapter(
      mangaId: mangaId,
      source: source,
      chapterId: chapterId,
    );
    emit(
      state.copyWith(
        prefetchedChapterIds: {...state.prefetchedChapterIds, chapterId},
      ),
    );
  }

  void recrawl({required BuildContext context, required String url}) async {
    // Await the re-crawl before refreshing: the fetches below read the
    // html cache the re-crawl writes, so starting them early serves the
    // stale page (#130).
    await _recrawlUseCase.execute(
      context: context,
      url: url,
      // Built-in sources (MangaDex) have no scraping use cases — their
      // getters throw UnimplementedError — so pass no scripts for them.
      scripts:
          state.source?.let(
            (e) => e.builtIn ? null : e.getMangaUseCase.scripts,
          ) ??
          [],
    );
    await init(useCache: false);
  }
}

/// Fits any thrown object into the state's `Exception?` error field.
Exception _asException(Object error) {
  return error is Exception ? error : Exception(error.toString());
}
