import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_screen_cubit_state.dart';
import 'state/manga_section_state.dart';
import 'state/tags_section_state.dart';

class SearchScreenCubit extends Cubit<SearchScreenCubitState> with AutoSubscriptionMixin {
  final SearchMangaUseCase searchMangaUseCase;
  final ListenListTagUseCase listenListTagUseCase;
  final GetCoverArtUseCase getCoverArtUseCase;

  static const _limit = 15;

  SearchScreenCubit({
    required this.searchMangaUseCase,
    required this.listenListTagUseCase,
    required this.getCoverArtUseCase,
    SearchScreenCubitState initState = const SearchScreenCubitState(),
  }) : super(initState) {
    addSubscription(listenListTagUseCase.listTagsStream.listen(_onReceiveTag));
  }

  void _onReceiveTag(List<Tag> tags) {
    update(
      tagsSectionState: state.tagsSectionState.copyWith(
        tags: tags,
        isLoading: false,
      ),
    );
  }

  void search() async {
    update(
      mangaSectionState: state.mangaSectionState.copyWith(
        isLoading: true,
      ),
    );

    final param = state.parameter;

    final result = await searchMangaUseCase.execute(
      title: param.title,
      includedTags: param.includedTags,
      includedTagsMode: param.includedTagsMode,
      excludedTags: param.excludedTags,
      excludedTagsMode: param.excludedTagsMode,
      offset: param.offset,
      limit: _limit,
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

      update(
        mangaSectionState: state.mangaSectionState.copyWith(
          mangas: [
            ...state.mangaSectionState.mangas,
            ...mangas?.toList() ?? []
          ],
          hasNextPage: (result.data.data?.length ?? 0) < _limit,
        ),
        parameter: param.copyWith(
          offset: (param.offset ?? 0) + _limit,
        ),
      );
    }

    if (result is Error<SearchResponse>) {
      update(
        mangaSectionState: state.mangaSectionState.copyWith(
          errorMessage: () => result.error.toString(),
        ),
      );
    }

    update(
      mangaSectionState: state.mangaSectionState.copyWith(
        isLoading: false,
      ),
    );
  }

  void next() async {
    if (!state.canFetchNextPage) return;

    update(
      mangaSectionState: state.mangaSectionState.copyWith(
        isPaging: true,
      ),
    );

    final param = state.parameter;

    final result = await searchMangaUseCase.execute(
      title: param.title,
      includedTags: param.includedTags,
      includedTagsMode: param.includedTagsMode,
      excludedTags: param.excludedTags,
      excludedTagsMode: param.excludedTagsMode,
      offset: param.offset,
      limit: _limit,
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

      update(
        mangaSectionState: state.mangaSectionState.copyWith(
          mangas: [
            ...state.mangaSectionState.mangas,
            ...mangas?.toList() ?? []
          ],
          hasNextPage: (result.data.data?.length ?? 0) < _limit,
        ),
        parameter: param.copyWith(
          offset: (param.offset ?? 0) + _limit,
        ),
      );
    }

    update(
      mangaSectionState: state.mangaSectionState.copyWith(
        isPaging: false,
      ),
    );
  }

  void update({
    MangaSectionState? mangaSectionState,
    TagsSectionState? tagsSectionState,
    SearchMangaParameter? parameter,
  }) {
    emit(
      state.copyWith(
        mangaSectionState: mangaSectionState,
        tagsSectionState: tagsSectionState,
        parameter: parameter,
      ),
    );
  }
}
