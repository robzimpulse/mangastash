import 'package:collection/collection.dart';
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
    emit(state.copyWith(isPagingNextPage: true));
    await _fetch();
    emit(state.copyWith(isPagingNextPage: false));
  }

  // TODO: move to another use case
  Future<String> _coverArtUrl(MangaData data) async {
    final cover = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.coverArt.rawValue,
    );
    final response = await getCoverArtUseCase.execute(
      mangaId: data.id ?? '',
      coverId: cover?.id ?? '',
    );
    if (response is Success<String>) {
      return response.data;
    }
    return '';
  }

  // TODO: move to another use case
  Future<List<String>> _authors(MangaData data) async {
    final authors = data.relationships?.where(
      (e) => e.type == Include.author.rawValue,
    );
    if (authors == null) return [];
    final promises = authors.map(
      (e) async {
        final response = await getAuthorUseCase.execute(
          authorId: e.id ?? '',
        );
        if (response is Success<AuthorResponse>) {
          return response.data.data?.attributes?.name;
        }
        return null;
      },
    );
    final result = await Future.wait(promises);
    return result.whereNotNull().toList();
  }

  Future<void> _fetch() async {
    final param = state.parameter;

    final result = await searchMangaUseCase.execute(
      parameter: param,
    );

    if (result is Success<SearchMangaResponse>) {
      final data = result.data.data?.map((element) async {
        return Manga.from(
          element,
          coverUrl: await _coverArtUrl(element),
          author: await _authors(element),
        );
      });

      final offset = result.data.offset ?? 0;
      final limit = result.data.limit ?? 0;
      List<Manga> mangas = [];
      if (data != null) mangas = await Future.wait(data);

      emit(
        state.copyWith(
          mangas: [...state.mangas, ...mangas],
          parameter: param.copyWith(
            limit: limit,
            offset: offset + limit,
          ),
          hasNextPage: (result.data.data?.length ?? 0) < limit,
        ),
      );
    }

    if (result is Error<SearchMangaResponse>) {
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

  void setFilter(List<MangaTag> tags) {
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
