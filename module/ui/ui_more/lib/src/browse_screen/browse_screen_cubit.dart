// BrowseScreenCubit: holds the global search-manga parameter of the Browse
// settings screen and persists every change through
// UpdateSearchParameterUseCase. Enabled sources moved to the source list
// screen (issue #115).
//
// Usage: `BrowseScreenCubit(updateSearchParameterUseCase: ...,
// listenSearchParameterUseCase: ...)`, then `update(parameter: p)`.
import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenState> {
  final UpdateSearchParameterUseCase _updateSearchParameterUseCase;

  BrowseScreenCubit({
    required this._updateSearchParameterUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    BrowseScreenState initialState = const BrowseScreenState(),
  })  : super(
          initialState.copyWith(
            parameter:
                listenSearchParameterUseCase.searchParameterState.valueOrNull,
          ),
        );

  void update({SearchMangaParameter? parameter}) {
    emit(state.copyWith(parameter: parameter));
    parameter?.let(
      (e) => _updateSearchParameterUseCase.updateSearchParameter(parameter: e),
    );
  }
}
