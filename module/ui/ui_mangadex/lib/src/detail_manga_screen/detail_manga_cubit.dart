import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'detail_manga_state.dart';

class DetailMangaCubit extends Cubit<DetailMangaState> {
  DetailMangaCubit({
    required Manga manga,
    DetailMangaState initialState = const DetailMangaState(),
  }) : super(initialState.copyWith(manga: manga));

  // TODO: implement this
  Future<void> init() async {

  }

}
