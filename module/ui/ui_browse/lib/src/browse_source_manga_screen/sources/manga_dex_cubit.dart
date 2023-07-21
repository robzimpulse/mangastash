import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import '../browse_source_manga_screen_cubit.dart';
import '../browse_source_manga_screen_cubit_state.dart';

class MangaDexCubit extends BrowseSourceMangaScreenCubit {
  final SearchMangaUseCase searchMangaUseCase;
  final ListenListTagUseCase listenListTagUseCase;
  final GetCoverArtUseCase getCoverArtUseCase;

  MangaDexCubit({
    required this.searchMangaUseCase,
    required this.listenListTagUseCase,
    required this.getCoverArtUseCase,
  }) : super(
          initialState: const BrowseSourceMangaScreenCubitState(
            parameter: SearchMangaParameter(
              includes: ['cover_art'],
              orders: {SearchOrders.rating: OrderDirections.descending},
            ),
          ),
        );

  @override
  void init({String? title}) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: state.parameter.copyWith(
          title: title,
          offset: 0,
        ),
      ),
    );
    await _fetch();
    emit(state.copyWith(isLoading: false));
  }

  @override
  void next() async {
    emit(state.copyWith(isPagingNextPage: true));
    await _fetch();
    emit(state.copyWith(isPagingNextPage: false));
  }

  Future<void> _fetch() async {
    final param = state.parameter;

    final result = await searchMangaUseCase.execute(
      parameter: param,
    );

    if (result is Success<SearchResponse>) {
      final mangas = result.data.data?.map((element) {
        final cover = element.relationships?.firstWhereOrNull(
          (e) => e.type == 'cover_art',
        );

        return Manga(
          id: element.id,
          title: element.attributes?.title?.en,
          coverUrl: getCoverArtUseCase.execute(
            mangaId: element.id ?? '',
            filename: cover?.attributes?.fileName ?? '',
          ),
        );
      });

      final offset = result.data.offset ?? 0;
      final limit = result.data.limit ?? 0;

      emit(
        state.copyWith(
          mangas: [...state.mangas, ...mangas?.toList() ?? []],
          parameter: param.copyWith(
            limit: limit,
            offset: offset + limit,
          ),
          hasNextPage: (result.data.data?.length ?? 0) < limit,
        ),
      );
    }

    if (result is Error<SearchResponse>) {
      emit(
        state.copyWith(
          errorMessage: () => result.error.toString(),
        ),
      );
    }
  }
}
