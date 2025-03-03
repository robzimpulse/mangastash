import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_search_param_configurator_screen_state.dart';

class MangaSearchParamConfiguratorScreenCubit
    extends Cubit<MangaSearchParamConfiguratorScreenState> {
  MangaSearchParamConfiguratorScreenCubit({
    MangaSearchParamConfiguratorScreenState initialState =
        const MangaSearchParamConfiguratorScreenState(),
  }) : super(initialState);

  void update({SearchMangaParameter? modified}) {
    emit(state.copyWith(modified: modified));
  }

  void reset() {
    emit(state.copyWith(modified: state.original));
  }
}
