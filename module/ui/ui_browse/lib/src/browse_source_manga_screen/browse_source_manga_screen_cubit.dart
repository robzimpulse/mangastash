import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_manga_screen_cubit_state.dart';

abstract class BrowseSourceMangaScreenCubit
    extends Cubit<BrowseSourceMangaScreenCubitState> {
  BrowseSourceMangaScreenCubit({
    BrowseSourceMangaScreenCubitState initialState =
        const BrowseSourceMangaScreenCubitState(),
  }) : super(initialState);

  void init({String? title});

  void next();

  void searchMode(bool value) {
    emit(state.copyWith(isSearchActive: value));
  }

  void updateLayout(MangaShelfItemLayout layout) {
    emit(state.copyWith(layout: layout));
  }

  void onTapFavorite() {
    emit(state.copyWith(isFavorite: true, isFilter: false, isLatest: false));
  }

  void onTapLatest() {
    emit(state.copyWith(isFavorite: false, isFilter: false, isLatest: true));
  }

  void onTapFilter() {
    emit(state.copyWith(isFavorite: false, isFilter: true, isLatest: false));
  }
}

class DefaultBrowseSourceMangaScreenCubit extends BrowseSourceMangaScreenCubit {
  @override
  void init({String? title}) {

  }

  @override
  void next() {
  }
}