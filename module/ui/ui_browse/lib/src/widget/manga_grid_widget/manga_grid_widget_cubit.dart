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

  MangaGridWidgetCubit({
    MangaGridWidgetState initialState = const MangaGridWidgetState(),
    required SearchMangaScreenCubit parentCubit,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required SearchMangaUseCase searchMangaUseCase,
    required RecrawlUseCase recrawlUseCase,
  }) : _searchMangaUseCase = searchMangaUseCase,
       _recrawlUseCase = recrawlUseCase,
       super(
         initialState.copyWith(
           parameter: initialState.parameter.copyWith(
             title: parentCubit.state.keyword,
           ),
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
      parentCubit.stream.distinct().listen((e) => init(keyword: e.keyword)),
    );
  }

  Future<void> init({String? keyword, bool refresh = false}) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: state.parameter.copyWith(
          title: keyword,
          offset: 0,
          page: 1,
          limit: 20,
        ),
      ),
    );

    if (refresh) await _clearMangaCache();

    await _fetchManga();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _clearMangaCache() async {
    final source = state.source;

    if (source == null) return;

    await _searchMangaUseCase.clear(
      parameter: SourceSearchMangaParameter(
        source: source,
        parameter: state.parameter,
      ),
    );
  }

  Future<void> _fetchManga() async {
    final source = state.source;

    if (source == null) return;

    final result = await _searchMangaUseCase.execute(
      parameter: SourceSearchMangaParameter(
        source: source,
        parameter: state.parameter,
      ),
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

  Future<void> next() async {
    if (!state.hasNextPage || state.isPagingNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetchManga();
    emit(state.copyWith(isPagingNextPage: false));
  }

  void recrawl({required BuildContext context, required String url}) async {
    await _recrawlUseCase.execute(context: context, url: url);
    await init(refresh: true);
  }
}
