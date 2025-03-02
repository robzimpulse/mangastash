import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaOnMangaDexUseCase {
  final MangaService _mangaService;

  GetMangaOnMangaDexUseCase({
    required MangaService mangaService,
  })  : _mangaService = mangaService;

  Future<Result<Manga>> execute({required String mangaId}) async {
    try {
      final result = await _mangaService.detail(
        id: mangaId,
        includes: [Include.author.rawValue, Include.coverArt.rawValue],
      );
      final manga = result.data;
      if (manga == null) return Error(Exception('Manga not found'));
      return Success(Manga.from(data: manga));
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
