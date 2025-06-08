import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenState> {
  final UpdateSearchParameterUseCase _updateSearchParameterUseCase;

  BrowseScreenCubit({
    required UpdateSearchParameterUseCase updateSearchParameterUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    BrowseScreenState initialState = const BrowseScreenState(),
  })  : _updateSearchParameterUseCase = updateSearchParameterUseCase,
        super(
          initialState.copyWith(
            parameter:
                listenSearchParameterUseCase.searchParameterState.valueOrNull,
          ),
        );

  void update({required SearchMangaParameter parameter}) {
    emit(state.copyWith(parameter: parameter));
    _updateSearchParameterUseCase.updateSearchParameter(parameter: parameter);
  }
}
