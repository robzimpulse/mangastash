import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_cubit_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenCubitState> {
  BrowseScreenCubit({
    BrowseScreenCubitState initialState = const BrowseScreenCubitState(
      sources: [
        // TODO: replace sources as soon as available
        MangaSource(
          iconUrl: 'https://www.mangadex.org/favicon.ico',
          name: 'Manga Dex',
          url: 'https://www.mangadex.org',
        ),
        MangaSource(
          iconUrl: 'https://www.asurascans.com/wp-content/uploads/2021/03/cropped-Group_1-1-32x32.png',
          name: 'Asura Scans',
          url: 'https://www.asurascans.com',
        ),
      ],
    ),
  }) : super(initialState);
}
