import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
  }) : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase;

  Future<Result<Manga>> execute({
    required MangaSourceEnum? source,
    required String mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    return switch (source) {
      MangaSourceEnum.mangadex => _getMangaOnMangaDexUseCase.execute(
          mangaId: mangaId,
        ),
      // TODO: Handle this case.
      MangaSourceEnum.asurascan => Future.value(
          Error(
            Exception('Unimplemented for ${source.name}'),
          ),
        ),
      // TODO: Handle this case.
      MangaSourceEnum.mangaclash => Future.value(
          Error(
            Exception('Unimplemented for ${source.name}'),
          ),
        ),
    };
  }
}
