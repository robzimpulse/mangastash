import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  MangaDetailCubit({
    MangaDetailState initialState = const MangaDetailState(),
  }) : super(initialState);

  Future<void> init() async {}

}
