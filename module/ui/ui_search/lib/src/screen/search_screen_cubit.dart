import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_screen_cubit_state.dart';
import 'state/manga_section_state.dart';
import 'state/tags_section_state.dart';

class SearchScreenCubit extends Cubit<SearchScreenCubitState> {
  final SearchMangaUseCase searchMangaUseCase;
  final ListTagUseCase listTagUseCase;

  SearchScreenCubit({
    required this.searchMangaUseCase,
    required this.listTagUseCase,
    SearchScreenCubitState initState = const SearchScreenCubitState(),
  }) : super(initState);

  void initialize() async {
    update(
      tagsSectionState: state.tagsSectionState.copyWith(
        isLoading: true,
      ),
    );

    final result = await listTagUseCase.execute();

    if (result is Success<List<Tag>>) {
      update(
        tagsSectionState: state.tagsSectionState.copyWith(
          tags: result.data,
        ),
      );
    }

    if (result is Error<List<Tag>>) {
      update(
        tagsSectionState: state.tagsSectionState.copyWith(
          errorMessage: () => result.error.toString(),
        ),
      );
    }

    update(
      tagsSectionState: state.tagsSectionState.copyWith(
        isLoading: false,
      ),
    );
  }

  Future<void> search() async {
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
    );

    if (result is Success<List<Manga>>) {
      update(
        mangaSectionState: state.mangaSectionState.copyWith(
          mangas: result.data,
        ),
      );
    }

    if (result is Error<List<Manga>>) {
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
