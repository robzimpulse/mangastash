import 'package:core_network/core_network.dart' as network;
import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_screen_cubit_state.dart';

class SearchScreenCubit extends Cubit<SearchScreenCubitState> {

  final SearchMangaUseCase _searchMangaUseCase;

  SearchScreenCubit({
    required SearchMangaUseCase searchMangaUseCase,
    SearchScreenCubitState initState = const SearchScreenCubitState(),
  }): _searchMangaUseCase = searchMangaUseCase, super(initState);

  Future<void> search(String title) async {
    emit(state.copyWith(isLoading: true));

    final result = await _searchMangaUseCase.execute(title: title);

    if (result is network.Success<List<Manga>>) {
      emit(state.copyWith(mangas: result.data));
    }

    if (result is network.Error<List<Manga>>) {
      emit(state.copyWith(errorMessage: () => result.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }

}