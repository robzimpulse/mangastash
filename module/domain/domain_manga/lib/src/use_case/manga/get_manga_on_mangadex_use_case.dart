import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../mixin/sync_mangas_mixin.dart';

class GetMangaOnMangaDexUseCase with SyncMangasMixin {
  final MangaService _mangaService;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final SyncMangasDao _syncMangasDao;

  GetMangaOnMangaDexUseCase({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaService mangaService,
    required SyncMangasDao syncMangasDao,
  })  : _mangaService = mangaService,
        _syncMangasDao = syncMangasDao,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Manga>> execute({required String mangaId}) async {
    final result = await _mangaServiceFirebase.get(id: mangaId);

    if (result != null) return Success(Manga.fromFirebaseService(result));

    try {
      final result = await _mangaService.detail(
        id: mangaId,
        includes: [Include.author.rawValue, Include.coverArt.rawValue],
      );

      final manga = result.data;

      if (manga == null) return Error(Exception('Manga not found'));

      final process = sync(
        syncMangasDao: _syncMangasDao,
        mangaTagServiceFirebase: _mangaTagServiceFirebase,
        mangaServiceFirebase: _mangaServiceFirebase,
        mangas: [
          Manga.from(data: manga).copyWith(
            source: MangaSourceEnum.mangadex,
          ),
        ],
      );

      final data = (await process).firstOrNull;

      if (data == null) {
        return Error(Exception('Error syncing manga'));
      }

      return Success(data);
    } catch (e) {
      return Error(e);
    }
  }
}
