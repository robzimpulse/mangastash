import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'home_cubit_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {

  final SearchService _searchService;

  HomeCubit({
    required SearchService searchService,
    HomeCubitState initState = const HomeCubitState(),
  }): _searchService = searchService, super(initState);

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 3));
    await _searchService.search(title: 'testing');

    emit(state.copyWith(isLoading: false));
  }

}