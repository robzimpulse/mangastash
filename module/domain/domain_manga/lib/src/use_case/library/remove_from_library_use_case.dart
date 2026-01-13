import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

class RemoveFromLibraryUseCase {
  final LibraryDao _libraryDao;

  RemoveFromLibraryUseCase({required LibraryDao libraryDao})
    : _libraryDao = libraryDao;

  Future<Result<bool>> execute({required Manga manga}) async {
    final mangaId = manga.id;

    if (mangaId == null) {
      return Error(Exception('Manga id is null'));
    }

    try {
      _libraryDao.remove(mangaId);
      return Success(true);
    } catch (e) {
      return Error(e);
    }
  }
}
