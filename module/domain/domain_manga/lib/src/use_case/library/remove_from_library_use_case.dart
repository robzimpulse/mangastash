import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

import '../source/listen_sources_use_case.dart';

/// Removes a manga row from the library. Removing is refused (no DB write)
/// while the manga's source is disabled: the managers filter disabled-source
/// rows out of the library streams, so a delete would permanently erase a row
/// the user can still see once the source is re-enabled.
class RemoveFromLibraryUseCase {
  final LibraryDao _libraryDao;
  final ListenSourcesUseCase _listenSourcesUseCase;

  RemoveFromLibraryUseCase({
    required LibraryDao libraryDao,
    required ListenSourcesUseCase listenSourcesUseCase,
  }) : _libraryDao = libraryDao,
       _listenSourcesUseCase = listenSourcesUseCase;

  Future<Result<bool>> execute({required Manga manga}) async {
    final mangaId = manga.id;

    if (mangaId == null) {
      return Error(Exception('Manga id is null'));
    }

    final source = manga.source;
    if (source == null) {
      return Error(Exception('Manga source is null'));
    }
    final enabled = {
      ..._listenSourcesUseCase.sourceStateStream.valueOrNull?.map((e) => e.name) ??
          const <String>[],
    };
    if (!enabled.contains(source)) {
      return Error(Exception('Source $source is disabled'));
    }

    try {
      _libraryDao.remove(mangaId);
      return Success(true);
    } catch (e) {
      return Error(e);
    }
  }
}
