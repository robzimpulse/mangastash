import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class RemoveFromLibraryUseCase {
  final MangaLibraryServiceFirebase _mangaLibraryServiceFirebase;

  RemoveFromLibraryUseCase({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
  }) : _mangaLibraryServiceFirebase = mangaLibraryServiceFirebase;

  Future<Result<bool>> execute({
    required Manga manga,
    required String userId,
  }) async {
    final mangaId = manga.id;
    if (mangaId == null) return Error(Exception('Manga id is null'));

    try {
      return Success(
        await _mangaLibraryServiceFirebase.remove(
          mangaId: mangaId,
          userId: userId,
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
