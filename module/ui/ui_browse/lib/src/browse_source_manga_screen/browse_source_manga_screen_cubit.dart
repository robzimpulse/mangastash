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
    var parameter = state.parameter;

    parameter = parameter.copyWith(
      orders: {
        SearchOrders.rating: OrderDirections.descending
      },
    );

    emit(state.copyWith(parameter: parameter));

    init();
  }

  void onTapLatest() {
    var parameter = state.parameter;

    parameter = parameter.copyWith(
      orders: {
        SearchOrders.latestUploadedChapter: OrderDirections.descending
      },
    );

    emit(state.copyWith(parameter: parameter));

    init();
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