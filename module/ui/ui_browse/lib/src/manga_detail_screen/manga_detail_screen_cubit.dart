import 'dart:async';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_screen_state.dart';

class MangaDetailScreenCubit extends Cubit<MangaDetailScreenState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _searchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final CrawlUrlUseCase _crawlUrlUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final GetAllChapterUseCase _getAllChapterUseCase;
  final SearchMangaUseCase _searchMangaUseCase;
  final UpdateChapterLastReadAtUseCase _updateChapterLastReadAtUseCase;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchMangaUseCase searchMangaUseCase,
    required SearchChapterUseCase searchChapterUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    required UpdateChapterLastReadAtUseCase updateChapterLastReadAtUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required GetAllChapterUseCase getAllChapterUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _searchMangaUseCase = searchMangaUseCase,
        _searchChapterUseCase = searchChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        _updateChapterLastReadAtUseCase = updateChapterLastReadAtUseCase,
        _getAllChapterUseCase = getAllChapterUseCase,
        super(
          initialState.copyWith(
            chapterParameter: listenSearchParameterUseCase
                .searchParameterState.valueOrNull
                ?.let((e) => SearchChapterParameter.from(e)),
            similarMangaParameter:
                listenSearchParameterUseCase.searchParameterState.valueOrNull,
          ),
        ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateMangaLibrary),
    );
    addSubscription(
      listenPrefetchUseCase.chapterIdsStream.distinct().listen(_updatePrefetch),
    );
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream
          .distinct()
          .listen(_updateHistories),
    );
  }

  void _updateMangaLibrary(List<Manga> library) {
    emit(
      state.copyWith(libraryMangaId: {...library.map((e) => e.id).nonNulls}),
    );
  }

  void _updatePrefetch(Set<String> prefetchedChapterId) {
    emit(state.copyWith(prefetchedChapterId: prefetchedChapterId));
  }

  void _updateHistories(List<History> histories) {
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

  // TODO: perform set read for multiple chapter
  // void updateLastRead(Chapter chapter) {
  //   _updateChapterLastReadAtUseCase.execute(chapter: chapter);
  // }

  Future<void> init({bool useCache = true}) async {
    emit(state.copyWith(isLoadingManga: true, errorManga: () => null));
    await _fetchManga(useCache: useCache);
    emit(state.copyWith(isLoadingManga: false));

    await Future.wait([
      initChapter(useCache: useCache),
      initSimilarManga(useCache: useCache),
    ]);
  }

  Future<void> initChapter({
    ChapterConfig? config,
    bool useCache = true,
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
    await _fetchChapter(useCache: useCache);
    emit(state.copyWith(isLoadingChapters: false));
  }

  Future<void> initSimilarManga({bool useCache = true}) async {
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
    await _fetchSimilarManga(useCache: useCache);
    emit(state.copyWith(isLoadingSimilarManga: false));
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

  Future<void> _fetchSimilarManga({bool useCache = true}) async {
    final source = state.source;
    final parameter = state.similarMangaParameter;

    if (source == null || parameter == null) return;

    final result = await _searchMangaUseCase.execute(
      source: source,
      parameter: parameter,
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
          similarManga: allMangas,
          hasNextPageSimilarManga: hasNextPage ?? allMangas.length < total,
          similarMangaParameter: parameter.copyWith(
            page: page + 1,
            offset: offset + limit,
            limit: limit,
          ),
          errorSimilarManga: () => null,
        ),
      );
    }

    if (result is Error<Pagination<Manga>>) {
      emit(state.copyWith(errorSimilarManga: () => result.error));
    }
  }

  Future<void> _fetchChapter({bool useCache = true}) async {
    final id = state.manga?.id ?? state.mangaId;
    final source = state.source;
    if (id == null || id.isEmpty || source == null) return;

    final result = await _searchChapterUseCase.execute(
      mangaId: id,
      source: source,
      parameter: state.chapterParameter,
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

  Future<void> nextChapter({bool useCache = true}) async {
    if (state.isLoadingChapters) return;
    if (!state.hasNextPageChapter || state.isPagingNextPageChapter) return;
    emit(state.copyWith(isPagingNextPageChapter: true));
    await _fetchChapter(useCache: useCache);
    emit(state.copyWith(isPagingNextPageChapter: false));
  }

  Future<void> nextSimilarManga({bool useCache = true}) async {
    if (state.isLoadingSimilarManga) return;
    if (!state.hasNextPageSimilarManga || state.isPagingNextPageSimilarManga) {
      return;
    }
    emit(state.copyWith(isPagingNextPageSimilarManga: true));
    await _fetchSimilarManga(useCache: useCache);
    emit(state.copyWith(isPagingNextPageSimilarManga: false));
  }

  Future<void> addToLibrary() async {
    final manga = state.manga;
    if (manga == null) return;
    if (state.isOnLibrary) {
      await _removeFromLibraryUseCase.execute(manga: manga);
    } else {
      await _addToLibraryUseCase.execute(manga: manga);
    }
  }

  Future<void> prefetch() async {
    final mangaId = state.manga?.id;
    final source = state.manga?.source?.let(
      (e) => SourceEnum.fromValue(name: e),
    );
    if (mangaId == null || source == null) return;
    final chapters = await _getAllChapterUseCase.execute(
      source: source,
      mangaId: mangaId,
      parameter: state.chapterParameter.copyWith(
        offset: 0,
        page: 1,
        limit: 20,
      ),
    );
    for (final chapterId in chapters.map((e) => e.id).nonNulls) {
      _prefetchChapterUseCase.prefetchChapter(
        mangaId: mangaId,
        source: source,
        chapterId: chapterId,
      );
    }
  }

  void recrawl({required String url}) async {
    await _crawlUrlUseCase.execute(url: url);
    await init();
  }
}
