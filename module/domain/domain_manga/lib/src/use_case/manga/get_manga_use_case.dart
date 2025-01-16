import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_manga_on_asura_scan_use_case.dart';
import 'get_manga_on_manga_clash_use_case.dart';
import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;
  final GetMangaOnMangaClashUseCase _getMangaOnMangaClashUseCase;
  final GetMangaOnAsuraScanUseCase _getMangaOnAsuraScanUseCase;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
    required GetMangaOnMangaClashUseCase getMangaOnMangaClashUseCase,
    required GetMangaOnAsuraScanUseCase getMangaOnAsuraScanUseCase,
  })  : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase,
        _getMangaOnMangaClashUseCase = getMangaOnMangaClashUseCase,
        _getMangaOnAsuraScanUseCase = getMangaOnAsuraScanUseCase;

  Future<Result<Manga>> execute({
    required MangaSourceEnum? source,
    required String mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    return switch (source) {
      MangaSourceEnum.mangadex => _getMangaOnMangaDexUseCase.execute(
          mangaId: mangaId,
        ),
      MangaSourceEnum.asurascan => _getMangaOnAsuraScanUseCase.execute(
          mangaId: mangaId,
        ),
      MangaSourceEnum.mangaclash => _getMangaOnMangaClashUseCase.execute(
          mangaId: mangaId,
        ),
    };
  }
}
