import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
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
  final RecrawlUseCase _recrawlUseCase;

  /// Monotonic request token: every init() bumps it, and responses from
  /// superseded fetches are dropped before emitting so a slow older response
  /// can never overwrite newer filter results or advance the parameter
  /// (issue #123).
  int _requestSeq = 0;

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
    required RecrawlUseCase recrawlUseCase,
  }) : _searchMangaUseCase = searchMangaUseCase,
       _addToLibraryUseCase = addToLibraryUseCase,
       _removeFromLibraryUseCase = removeFromLibraryUseCase,
       _prefetchMangaUseCase = prefetchMangaUseCase,
       _prefetchChapterUseCase = prefetchChapterUseCase,
       _getTagsUseCase = getTagsUseCase,
       _recrawlUseCase = recrawlUseCase,
       super(
         initialState.copyWith(
           parameter: initialState.parameter.merge(
             listenSearchParameterUseCase.searchParameterState.valueOrNull,
           ),
         ),
       ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryMangaIds.distinct().listen(
        _updateLibraryState,
      ),
    );
    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream.distinct().listen(
        _updatePrefetchState,
      ),
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
    bool refresh = false,
  }) async {
    final seq = ++_requestSeq;
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        // A new epoch reclaims the paging flag from any superseded next()
        // (review on #160) — the flag is per-epoch, not per-cubit-lifetime.
        isPagingNextPage: false,
        parameter: (parameter ?? state.parameter).copyWith(
          offset: 0,
          page: 1,
          limit: 20,
        ),
      ),
    );

    try {
      if (refresh) await _clearMangaCache();

      await Future.wait([
        _fetchManga(seq: seq),
        _fetchTags(seq: seq, useCache: !refresh),
      ]);
    } catch (e) {
      if (seq == _requestSeq) {
        emit(state.copyWith(error: () => _asException(e)));
      }
    } finally {
      // Gated by the token: an older init finishing must not clear the
      // loading state of a newer one that is still in flight (issue #123).
      if (seq == _requestSeq) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _fetchTags({required bool useCache, required int seq}) async {
    final source = state.source;

    if (source == null) return;

    try {
      final result = await _getTagsUseCase.execute(
        source: source,
        useCache: useCache,
      );

      if (seq != _requestSeq) return;

      if (result is Success<List<Tag>>) {
        emit(state.copyWith(tags: result.data));
      }

      if (result is Error<List<Tag>>) {
        emit(state.copyWith(error: () => result.error));
      }
    } catch (e) {
      if (seq != _requestSeq) return;
      emit(state.copyWith(error: () => _asException(e)));
    }
  }

  Future<void> _clearMangaCache() async {
    final source = state.source;

    if (source == null) return;

    await _searchMangaUseCase.clear(
      parameter: SourceSearchMangaParameter(
        source: source.name,
        parameter: state.parameter,
      ),
    );
  }

  Future<void> _fetchManga({required int seq}) async {
    final source = state.source;

    if (source == null) return;

    try {
      final result = await _searchMangaUseCase.execute(
        parameter: SourceSearchMangaParameter(
          source: source.name,
          parameter: state.parameter,
        ),
      );

      // Drop responses superseded by a newer init before emitting (#123).
      if (seq != _requestSeq) return;

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
        emit(state.copyWith(error: () => result.error));
      }
    } catch (e) {
      // A throw must never strand the loading flags (issue #122).
      if (seq != _requestSeq) return;
      emit(state.copyWith(error: () => _asException(e)));
    }
  }

  Future<void> next() async {
    // A next() started while init() is still in flight would share its
    // epoch — both fetches append and advance the page by +2 (review on
    // #160; same guard shape as MangaDetailScreenCubit.nextChapter).
    if (state.isLoading) return;
    if (!state.hasNextPage || state.isPagingNextPage) return;
    // Belongs to the current request epoch: a newer init bumps the token and
    // this fetch's response is dropped automatically.
    final seq = _requestSeq;
    emit(state.copyWith(isPagingNextPage: true));
    try {
      await _fetchManga(seq: seq);
    } finally {
      // Gated by the epoch: a superseded next() must not clear the paging
      // flag of the newer epoch whose init reclaimed it (review on #160).
      if (seq == _requestSeq) {
        emit(state.copyWith(isPagingNextPage: false));
      }
    }
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
    final source = manga.source?.let(Sources.fromName);
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

  void recrawl({required BuildContext context, required String url}) async {
    await _recrawlUseCase.execute(
      context: context,
      url: url,
      // Built-in sources (MangaDex) have no scraping use cases — their
      // getters throw UnimplementedError — so pass no scripts for them.
      scripts:
          state.source?.let(
            (e) => e.builtIn ? null : e.searchMangaUseCase.scripts,
          ) ??
          [],
    );
    await init(refresh: true);
  }
}

/// Fits any thrown object into the state's `Exception?` error field.
Exception _asException(Object error) {
  return error is Exception ? error : Exception(error.toString());
}
