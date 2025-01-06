import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_manga_on_manga_clash_use_case.dart';
import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;
  final GetMangaOnMangaClashUseCase _getMangaOnMangaClashUseCase;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
    required GetMangaOnMangaClashUseCase getMangaOnMangaClashUseCase,
  })  : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase,
        _getMangaOnMangaClashUseCase = getMangaOnMangaClashUseCase;

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
      MangaSourceEnum.mangaclash => _getMangaOnMangaClashUseCase.execute(
          mangaId: mangaId,
        ),
    };
  }
}
