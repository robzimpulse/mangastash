import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../../search_manga_screen/search_manga_screen_cubit.dart';
import 'manga_grid_widget_state.dart';

class MangaGridWidgetCubit extends Cubit<MangaGridWidgetState>
    with AutoSubscriptionMixin {
  final SearchMangaUseCase _searchMangaUseCase;
  final RecrawlUseCase _recrawlUseCase;
  final PrefetchMangaUseCase _prefetchMangaUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;

  /// Monotonic request token: every init() bumps it, and responses from
  /// superseded fetches are dropped before emitting so a slow older response
  /// can never overwrite newer results or advance the parameter
  /// (issue #123).
  int _requestSeq = 0;

  MangaGridWidgetCubit({
    MangaGridWidgetState initialState = const MangaGridWidgetState(),
    required SearchMangaScreenCubit parentCubit,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required SearchMangaUseCase searchMangaUseCase,
    required RecrawlUseCase recrawlUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
  }) : _searchMangaUseCase = searchMangaUseCase,
       _recrawlUseCase = recrawlUseCase,
       _removeFromLibraryUseCase = removeFromLibraryUseCase,
       _addToLibraryUseCase = addToLibraryUseCase,
       _prefetchMangaUseCase = prefetchMangaUseCase,
       _prefetchChapterUseCase = prefetchChapterUseCase,
       super(
         initialState.copyWith(
           parameter: initialState.parameter.merge(parentCubit.state.parameter),
         ),
       ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryMangaIds.distinct().listen(
        (e) => emit(state.copyWith(libraryMangaIds: e)),
      ),
    );
    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream.distinct().listen(
        (e) => emit(state.copyWith(prefetchedMangaIds: e)),
      ),
    );
    addSubscription(
      parentCubit.stream.distinct().listen((e) => init(parameter: e.parameter)),
    );
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

      await _fetchManga(seq: seq);
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

  void prefetch({required List<Manga> mangas}) {
    for (final manga in mangas) {
      final id = manga.id;
      final source = manga.source?.let(Sources.fromName);
      if (id == null || source == null) continue;
      _prefetchMangaUseCase.prefetchManga(mangaId: id, source: source);
      _prefetchChapterUseCase.prefetchChapters(mangaId: id, source: source);
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

  void download({required Manga manga}) {
    final id = manga.id;
    final source = manga.source;
    if (id == null || source == null) return;
    // TODO: add download manga
  }
}

/// Fits any thrown object into the state's `Exception?` error field.
Exception _asException(Object error) {
  return error is Exception ? error : Exception(error.toString());
}
