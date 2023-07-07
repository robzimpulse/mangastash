import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'home_cubit_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {

  HomeCubit({
    required SearchMangaUseCase searchMangaUseCase,
    HomeCubitState initState = const HomeCubitState(),
  }): super(initState);

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    // TODO: populate most popular manga here

    emit(state.copyWith(isLoading: false));
  }

}