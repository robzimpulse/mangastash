import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

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
  })  : _searchMangaUseCase = searchMangaUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _prefetchMangaUseCase = prefetchMangaUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        _getTagsUseCase = getTagsUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        super(
          initialState.copyWith(
            parameter:
                listenSearchParameterUseCase.searchParameterState.valueOrNull,
          ),
        ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateLibraryState),
    );
    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream
          .distinct()
          .listen(_updatePrefetchState),
    );
  }

  void _updateLibraryState(List<Manga> libraryState) {
    emit(state.copyWith(libraries: libraryState));
  }

  void _updatePrefetchState(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  Future<void> init({
    String? title,
    SearchMangaParameter? parameter,
    bool useCache = true,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: (parameter ?? state.parameter).copyWith(
          title: title,
          offset: 0,
          page: 1,
          limit: 20,
        ),
      ),
    );

    await Future.wait([
      _fetchManga(useCache: useCache),
      _fetchTags(useCache: useCache),
    ]);

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchTags({bool useCache = true}) async {
    final source = state.source?.name;

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
    final source = state.source?.name;

    if (source == null) return;

    final result = await _searchMangaUseCase.execute(
        source: source, parameter: state.parameter, useCache: useCache);

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

  void update({
    MangaShelfItemLayout? layout,
    bool? isSearchActive,
  }) {
    emit(
      state.copyWith(
        layout: layout,
        isSearchActive: isSearchActive,
      ),
    );
  }

  Future<void> addToLibrary({required Manga manga}) async {
    if (state.libraries.contains(manga)) {
      await _removeFromLibraryUseCase.execute(manga: manga);
    } else {
      await _addToLibraryUseCase.execute(manga: manga);
    }
  }

  void prefetch({required Manga manga}) {
    final id = manga.id;
    final source = manga.source;
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

  void recrawl() async {
    final parameter = state.parameter.copyWith(page: 1);
    final source = state.source?.name;
    final url = source == Source.mangaclash().name
        ? parameter.mangaclash
        : source == Source.asurascan().name
            ? parameter.asurascan
            : null;
    if (url == null) return;
    await _crawlUrlUseCase.execute(url: url);
    await init(title: state.parameter.title);
  }
}
