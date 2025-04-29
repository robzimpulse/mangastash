import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_manga_mixin.dart';

class GetMangaOnMangaDexUseCase with SyncMangaMixin {
  final MangaService _mangaService;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;

  GetMangaOnMangaDexUseCase({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaService mangaService,
  })  : _mangaService = mangaService,
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
      return Success(
        await sync(
          mangaTagServiceFirebase: _mangaTagServiceFirebase,
          mangaServiceFirebase: _mangaServiceFirebase,
          manga: Manga.from(data: manga).copyWith(
            source: MangaSourceEnum.mangadex,
          ),
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
