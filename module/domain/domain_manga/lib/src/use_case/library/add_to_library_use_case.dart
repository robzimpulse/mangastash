import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

class AddToLibraryUseCase {
  final LibraryDao _libraryDao;

  const AddToLibraryUseCase({
    required LibraryDao libraryDao,
  }) : _libraryDao = libraryDao;

  Future<Result<bool>> execute({required Manga manga}) async {
    final mangaId = manga.id;

    if (mangaId == null) {
      return Error(Exception('Manga id is null'));
    }

    try {
      _libraryDao.add(mangaId);
      return Success(true);
    } catch (e) {
      return Error(e);
    }
  }
}
