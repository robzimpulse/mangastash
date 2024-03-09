import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_dex_state.dart';

class BrowseMangaDexCubit extends Cubit<BrowseMangaDexState> {
  final SearchMangaUseCase searchMangaUseCase;
  final GetCoverArtUseCase getCoverArtUseCase;
  final GetAuthorUseCase getAuthorUseCase;

  BrowseMangaDexCubit({
    required this.searchMangaUseCase,
    required this.getCoverArtUseCase,
    required this.getAuthorUseCase,
    BrowseMangaDexState initialState = const BrowseMangaDexState(),
  }) : super(initialState);

  Future<void> init({String? title}) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: state.parameter.copyWith(
          title: title,
          offset: 0,
          limit: 20,
        ),
      ),
    );
    await _fetch();
    emit(state.copyWith(isLoading: false));
  }

  void next() async {
    if (!state.hasNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetch();
    emit(state.copyWith(isPagingNextPage: false));
  }

  Future<void> _fetch() async {
    final param = state.parameter;

    final result = await searchMangaUseCase.execute(
      parameter: param,
    );

    if (result is Success<PaginationMangaDeprecated>) {
      final offset = result.data.offset ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final mangas = result.data.mangas ?? [];

      emit(
        state.copyWith(
          mangas: [...state.mangas, ...mangas],
          parameter: param.copyWith(
            limit: limit,
            offset: offset + limit,
          ),
          hasNextPage: mangas.length < total,
        ),
      );
    }

    if (result is Error<PaginationMangaDeprecated>) {
      emit(
        state.copyWith(
          errorMessage: () => result.error.toString(),
        ),
      );
    }
  }

  void searchMode(bool value) {
    emit(state.copyWith(isSearchActive: value));
  }

  void updateLayout(MangaShelfItemLayout layout) {
    emit(state.copyWith(layout: layout));
  }

  void onTapFavorite() {
    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          orders: {SearchOrders.rating: OrderDirections.descending},
          includedTags: [],
          excludedTags: [],
        ),
      ),
    );
    init();
  }

  void onTapLatest() {
    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          orders: {
            SearchOrders.latestUploadedChapter: OrderDirections.descending
          },
          includedTags: [],
          excludedTags: [],
        ),
      ),
    );
    init();
  }

  void setFilter(List<MangaTagDeprecated> tags) {
    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          orders: {},
          includedTags: tags
              .where((e) => e.isIncluded)
              .map((e) => e.id)
              .whereType<String>()
              .toList(),
          excludedTags: tags
              .where((e) => e.isExcluded)
              .map((e) => e.id)
              .whereType<String>()
              .toList(),
        ),
      ),
    );
    init();
  }
}
