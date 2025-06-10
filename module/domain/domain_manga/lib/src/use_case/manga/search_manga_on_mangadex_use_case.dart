import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_mangas_mixin.dart';

class SearchMangaOnMangaDexUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaOnMangaDexUseCase({
    required MangaRepository mangaRepository,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaRepository = mangaRepository,
        _mangaDao = mangaDao,
        _logBox = logBox;

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

      return Success(
        Pagination(
          data: await sync(
            logBox: _logBox,
            mangaDao: _mangaDao,
            values: [
              ...?result.data?.map(
                (e) => Manga.from(data: e).copyWith(
                  source: Source.mangadex().name,
                ),
              ),
            ],
          ),
          offset: result.offset?.toInt(),
          limit: result.limit?.toInt() ?? 0,
          total: result.total?.toInt() ?? 0,
          // TODO: add metadata (all available tags / order / filter)
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
