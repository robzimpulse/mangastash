import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class CheckMangaExistsOnLibraryUseCase {

  final MangaLibraryServiceFirebase _mangaLibraryServiceFirebase;

  CheckMangaExistsOnLibraryUseCase({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
  }) : _mangaLibraryServiceFirebase = mangaLibraryServiceFirebase;

  Future<Result<bool>> execute({
    required Manga manga,
    required String userId,
  }) async {
    try {
      return Success(await _mangaLibraryServiceFirebase.exists(manga, userId));
    } catch (e) {
      return Error(e);
    }
  }

}