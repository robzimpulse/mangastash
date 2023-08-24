import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_screen_cubit_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenCubitState> {
  BrowseSourceScreenCubit({
    BrowseSourceScreenCubitState initialState =
        const BrowseSourceScreenCubitState(
      sources: [MangaSource.mangadex, MangaSource.asurascans],
    ),
  }) : super(initialState);
}
