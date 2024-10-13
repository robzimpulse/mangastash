import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class AddToLibraryUseCase {
  final MangaLibraryServiceFirebase _mangaLibraryServiceFirebase;

  AddToLibraryUseCase({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
  }) : _mangaLibraryServiceFirebase = mangaLibraryServiceFirebase;

  Future<Result<bool>> execute({
    required Manga manga,
    required String userId,
  }) async {
    return _mangaLibraryServiceFirebase.add(manga, userId);
  }
}
