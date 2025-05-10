import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../mixin/sync_mangas_mixin.dart';

class SearchMangaOnMangaDexUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final SyncMangasDao _syncMangasDao;

  const SearchMangaOnMangaDexUseCase({
    required MangaRepository mangaRepository,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required SyncMangasDao syncMangasDao,
  })  : _mangaRepository = mangaRepository,
        _syncMangasDao = syncMangasDao,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    try {
      final result = await _mangaRepository.search(
        parameter: parameter.copyWith(
          includes: [
            ...?parameter.includes,
            Include.author,
            Include.coverArt,
          ],
        ),
      );

      final mangas = result.data?.map(
        (e) => Manga.from(data: e).copyWith(
          source: MangaSourceEnum.mangadex,
        ),
      );

      return Success(
        Pagination(
          data: await sync(
            syncMangasDao: _syncMangasDao,
            mangaTagServiceFirebase: _mangaTagServiceFirebase,
            mangaServiceFirebase: _mangaServiceFirebase,
            mangas: mangas?.toList() ?? [],
          ),
          offset: result.offset?.toInt(),
          limit: result.limit?.toInt() ?? 0,
          total: result.total?.toInt() ?? 0,
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
