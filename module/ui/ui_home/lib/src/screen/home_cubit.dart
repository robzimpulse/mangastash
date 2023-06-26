import 'package:safe_bloc/safe_bloc.dart';

import 'home_cubit_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {

  HomeCubit({
    HomeCubitState initState = const HomeCubitState(),
  }): super(initState);

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 3));

    emit(state.copyWith(isLoading: false));
  }

}