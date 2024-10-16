import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../library/get_manga_from_library_use_case.dart';
import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
    required GetMangaFromLibraryUseCase getMangaFromLibraryUseCase,
  })  : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase;

  Future<Result<Manga>> execute({
    required MangaSourceEnum? source,
    required String mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<Manga> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _getMangaOnMangaDexUseCase.execute(mangaId: mangaId);
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    return result;
  }
}
