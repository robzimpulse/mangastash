import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenState> {
  BrowseScreenCubit({
    BrowseScreenState initialState = const BrowseScreenState(),
  }) : super(initialState);

  void update({SearchMangaParameter? modified}) {
    emit(state.copyWith(parameter: modified));
  }

}
