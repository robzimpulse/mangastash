import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetMangaOnMangaClashUseCase {
  final MangaServiceFirebase _mangaServiceFirebase;

  GetMangaOnMangaClashUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
  })  : _mangaServiceFirebase = mangaServiceFirebase;

  Future<Result<Manga>> execute({required String mangaId}) async {
    final result = await _mangaServiceFirebase.get(mangaId);
    return result == null ? Error('Data not found') : Success(result);
  }
}
