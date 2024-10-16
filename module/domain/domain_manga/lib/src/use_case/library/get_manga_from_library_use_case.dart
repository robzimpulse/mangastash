import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetMangaFromLibraryUseCase {
  final MangaLibraryServiceFirebase _mangaLibraryServiceFirebase;

  GetMangaFromLibraryUseCase({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
  }) : _mangaLibraryServiceFirebase = mangaLibraryServiceFirebase;

  Future<Result<List<Manga>>> execute({
    required String userId,
  }) async {
    try {
      return Success(await _mangaLibraryServiceFirebase.get(userId));
    } catch (e) {
      return Error(e);
    }
  }

}