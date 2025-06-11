import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
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

  void update({
    SearchMangaParameter? parameter,
    List<Source>? sources,
  }) {
    emit(state.copyWith(parameter: parameter, sources: sources));
    // TODO: update available sources
    parameter?.let(
      (e) => _updateSearchParameterUseCase.updateSearchParameter(parameter: e),
    );
  }
}
