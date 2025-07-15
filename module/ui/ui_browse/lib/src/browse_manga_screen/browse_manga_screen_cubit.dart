import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_manga_screen_state.dart';

class BrowseMangaScreenCubit extends Cubit<BrowseMangaScreenState>
    with AutoSubscriptionMixin {
  final SearchMangaUseCase _searchMangaUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final PrefetchMangaUseCase _prefetchMangaUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final GetTagsUseCase _getTagsUseCase;
  final CrawlUrlUseCase _crawlUrlUseCase;
  final BaseCacheManager _cacheManager;

  BrowseMangaScreenCubit({
    required BrowseMangaScreenState initialState,
    required SearchMangaUseCase searchMangaUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required GetTagsUseCase getTagsUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required BaseCacheManager cacheManager,
  })  : _searchMangaUseCase = searchMangaUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _prefetchMangaUseCase = prefetchMangaUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        _getTagsUseCase = getTagsUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        _cacheManager = cacheManager,
        super(
          initialState.copyWith(
            parameter:
                listenSearchParameterUseCase.searchParameterState.valueOrNull,
          ),
        ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryMangaIds
          .distinct()
          .listen(_updateLibraryState),
    );
    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream
          .distinct()
          .listen(_updatePrefetchState),
    );
  }

  void _updateLibraryState(Set<String> libraryMangaIds) {
    emit(state.copyWith(libraryMangaIds: libraryMangaIds));
  }

  void _updatePrefetchState(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  Future<void> init({
    SearchMangaParameter? parameter,
    bool useCache = true,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: (parameter ?? state.parameter).copyWith(
          offset: 0,
          page: 1,
          limit: 20,
        ),
      ),
    );

    if (!useCache) {
      await Future.wait(state.cacheKeys.map(_cacheManager.removeFile));
      emit(state.copyWith(cacheKeys: []));
    }

    await Future.wait([
      _fetchManga(useCache: useCache),
      _fetchTags(useCache: useCache),
    ]);

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchTags({bool useCache = true}) async {
    final source = state.source;

    if (source == null) return;

    final result = await _getTagsUseCase.execute(
      source: source,
      useCache: useCache,
    );

    if (result is Success<List<Tag>>) {
      emit(state.copyWith(tags: result.data));
    }

    if (result is Error<List<Tag>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> _fetchManga({bool useCache = true}) async {
    final source = state.source;

    if (source == null) return;

    final result = await _searchMangaUseCase.execute(
      source: source,
      parameter: state.parameter,
      useCache: useCache,
    );

    if (result is Success<Pagination<Manga>>) {
      final offset = result.data.offset ?? 0;
      final page = result.data.page ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final mangas = result.data.data ?? [];
      final hasNextPage = result.data.hasNextPage;

      final allMangas = [...state.mangas, ...mangas].distinct();

      emit(
        state.copyWith(
          cacheKeys: [
            ...state.cacheKeys,
            '$source-${state.parameter.toJsonString()}',
            ...[
              switch (source) {
                SourceEnum.mangadex => null,
                SourceEnum.mangaclash => state.parameter.mangaclash,
                SourceEnum.asurascan => state.parameter.asurascan,
              },
            ].nonNulls,
          ],
          mangas: allMangas,
          hasNextPage: hasNextPage ?? allMangas.length < total,
          parameter: state.parameter.copyWith(
            page: page + 1,
            offset: offset + limit,
            limit: limit,
          ),
          error: () => null,
        ),
      );
    }

    if (result is Error<Pagination<Manga>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> next({bool useCache = true}) async {
    if (!state.hasNextPage || state.isPagingNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetchManga(useCache: useCache);
    emit(state.copyWith(isPagingNextPage: false));
  }

  void update({bool? isSearchActive}) {
    emit(state.copyWith(isSearchActive: isSearchActive));
  }

  Future<void> addToLibrary({required Manga manga}) async {
    if (state.libraryMangaIds.contains(manga.id)) {
      await _removeFromLibraryUseCase.execute(manga: manga);
    } else {
      await _addToLibraryUseCase.execute(manga: manga);
    }
  }

  void prefetch({required Manga manga}) {
    final id = manga.id;
    final source = manga.source?.let((e) => SourceEnum.fromValue(name: e));
    if (id == null || source == null) return;
    _prefetchMangaUseCase.prefetchManga(mangaId: id, source: source);
    _prefetchChapterUseCase.prefetchChapters(mangaId: id, source: source);
  }

  void download({required Manga manga}) {
    final id = manga.id;
    final source = manga.source;
    if (id == null || source == null) return;
    // TODO: add download manga
  }

  void recrawl({required String url}) async {
    // final parameter = state.parameter.copyWith(page: 1);
    // final source = state.source;
    // final url = source == SourceEnum.mangaclash
    //     ? parameter.mangaclash
    //     : source == SourceEnum.asurascan
    //         ? parameter.asurascan
    //         : null;
    // if (url == null) return;
    await _crawlUrlUseCase.execute(url: url);
    await init(parameter: state.parameter);
  }
}
