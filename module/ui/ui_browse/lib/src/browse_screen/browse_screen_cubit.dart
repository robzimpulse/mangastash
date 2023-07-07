import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_cubit_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenCubitState> {

  BrowseScreenCubit({
    BrowseScreenCubitState initialState = const BrowseScreenCubitState(
      sources: [
        MangaSource(name: 'Manga Dex', url: 'https://www.mangadex.org'),
        MangaSource(name: 'Manga TX', url: 'www.mangatx.com'),
        MangaSource(name: 'Manga Clash', url: 'www.mangaclash.com'),
        MangaSource(name: 'Manga Sail', url: 'https://www.mangasail.net'),
      ],
    ),
  }): super(initialState);
}