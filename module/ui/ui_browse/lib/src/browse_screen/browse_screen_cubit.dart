import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_cubit_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenCubitState> {
  BrowseScreenCubit({
    BrowseScreenCubitState initialState = const BrowseScreenCubitState(
      sources: [MangaSource.mangadex, MangaSource.asurascan],
    ),
  }) : super(initialState);
}
