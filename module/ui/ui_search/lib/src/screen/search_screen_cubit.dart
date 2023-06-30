import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_screen_cubit_state.dart';

class SearchScreenCubit extends Cubit<SearchScreenCubitState> {

  final SearchMangaUseCase searchMangaUseCase;
  final ListTagUseCase listTagUseCase;

  SearchScreenCubit({
    required this.searchMangaUseCase,
    required this.listTagUseCase,
    SearchScreenCubitState initState = const SearchScreenCubitState(),
  }): super(initState);

  void initialize() async {
    emit(
      state.copyWith(
        tagsSectionState: state.tagsSectionState.copyWith(
          isLoading: true,
        ),
      ),
    );

    final result = await listTagUseCase.execute();

    if (result is Success<List<Tag>>) {
      emit(
        state.copyWith(
          tagsSectionState: state.tagsSectionState.copyWith(
            tags: result.data,
          ),
        ),
      );
    }

    if (result is Error<List<Tag>>) {
      emit(
        state.copyWith(
          tagsSectionState: state.tagsSectionState.copyWith(
            errorMessage: () => result.error.toString(),
          ),
        ),
      );
    }

    emit(
      state.copyWith(
        tagsSectionState: state.tagsSectionState.copyWith(
          isLoading: false,
        ),
      ),
    );
  }

  Future<void> search(String title) async {
    emit(
      state.copyWith(
        mangaSectionState: state.mangaSectionState.copyWith(
          isLoading: true,
        ),
      ),
    );

    final result = await searchMangaUseCase.execute(title: title);

    if (result is Success<List<Manga>>) {
      emit(
        state.copyWith(
          mangaSectionState: state.mangaSectionState.copyWith(
            mangas: result.data,
          ),
        ),
      );
    }

    if (result is Error<List<Manga>>) {
      emit(
        state.copyWith(
          mangaSectionState: state.mangaSectionState.copyWith(
            errorMessage: () => result.error.toString(),
          ),
        ),
      );
    }

    emit(
      state.copyWith(
        mangaSectionState: state.mangaSectionState.copyWith(
          isLoading: false,
        ),
      ),
    );
  }

}