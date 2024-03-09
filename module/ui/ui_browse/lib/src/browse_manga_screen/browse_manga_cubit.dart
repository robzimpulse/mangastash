import 'package:safe_bloc/safe_bloc.dart';

import 'browse_manga_state.dart';

class BrowseMangaCubit extends Cubit<BrowseMangaState> {
  BrowseMangaCubit({
    BrowseMangaState initialState = const BrowseMangaState(),
  }) : super(initialState);

  Future<void> init() async {

  }
}
