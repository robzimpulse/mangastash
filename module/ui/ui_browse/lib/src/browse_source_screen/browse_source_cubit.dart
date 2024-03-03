import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_state.dart';

class BrowseSourceCubit extends Cubit<BrowseSourceState> {
  BrowseSourceCubit({
    BrowseSourceState initialState = const BrowseSourceState(
      sources: [
        // TODO: get all manga source from storage
        MangaSource(
          iconUrl: 'https://www.mangadex.org/favicon.ico',
          name: 'Manga Dex',
          url: 'https://www.mangadex.org',
          id: 'manga_dex',
        ),
        MangaSource(
          iconUrl:
              'https://www.asurascans.com/wp-content/uploads/2021/03/cropped-Group_1-1-32x32.png',
          name: 'Asura Scans',
          url: 'https://www.asurascans.com',
          id: 'asura_scans',
        ),
      ],
    ),
  }) : super(initialState);
}
