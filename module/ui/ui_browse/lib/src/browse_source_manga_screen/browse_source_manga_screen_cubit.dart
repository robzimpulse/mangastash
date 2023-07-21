import 'package:domain_manga/domain_manga.dart';
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
    final orders = {SearchOrders.rating: OrderDirections.descending};
    emit(state.copyWith(parameter: state.parameter.copyWith(orders: orders)));
    init();
  }

  void onTapLatest() {
    final orders = {
      SearchOrders.latestUploadedChapter: OrderDirections.descending
    };
    emit(state.copyWith(parameter: state.parameter.copyWith(orders: orders)));
    init();
  }

  void onTapFilter();
}

class DefaultBrowseSourceMangaScreenCubit extends BrowseSourceMangaScreenCubit {
  @override
  void init({String? title}) {}

  @override
  void next() {}

  @override
  void onTapFilter() {}
}
