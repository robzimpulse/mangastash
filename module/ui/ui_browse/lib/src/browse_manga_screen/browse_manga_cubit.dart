import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_state.dart';

class BrowseMangaCubit extends Cubit<BrowseMangaState> {
  BrowseMangaCubit({
    BrowseMangaState initialState = const BrowseMangaState(
      layout: MangaShelfItemLayout.comfortableGrid,
    ),
  }) : super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isLoading: false));
  }

  Future<void> next() async {

  }

  void update({MangaShelfItemLayout? layout}) {
    emit(state.copyWith(layout: layout));
  }
}
