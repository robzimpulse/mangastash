import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_mangas_mixin.dart';

class GetMangaOnMangaDexUseCase with SyncMangasMixin {
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaOnMangaDexUseCase({
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaService = mangaService,
        _mangaDao = mangaDao,
        _logBox = logBox;

  Future<Result<Manga>> execute({required String mangaId}) async {
    final raw = await _mangaDao.search(ids: [mangaId]);

    final result = Manga.fromDatabase(raw.firstOrNull);

    if (result != null) {
      return Success(result);
    }

    try {
      final result = await _mangaService.detail(
        id: mangaId,
        includes: [Include.author.rawValue, Include.coverArt.rawValue],
      );

      final manga = result.data;

      if (manga == null) {
        return Error(Exception('Manga not found'));
      }

      final process = await sync(
        logBox: _logBox,
        mangaDao: _mangaDao,
        values: [
          Manga.from(data: manga).copyWith(
            source: Source.mangadex().name,
          ),
        ],
      );

      final data = process.firstOrNull;

      if (data == null) {
        return Error(Exception('Error syncing manga'));
      }

      return Success(data);
    } catch (e) {
      return Error(e);
    }
  }
}
