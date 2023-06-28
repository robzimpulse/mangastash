import 'package:core_network/core_network.dart' as network;
import 'package:data_manga/manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'home_cubit_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {

  final SearchMangaUseCase _searchMangaUseCase;

  HomeCubit({
    required SearchMangaUseCase searchMangaUseCase,
    HomeCubitState initState = const HomeCubitState(),
  }): _searchMangaUseCase = searchMangaUseCase, super(initState);

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    // TODO: populate most popular manga here

    emit(state.copyWith(isLoading: false));
  }

}