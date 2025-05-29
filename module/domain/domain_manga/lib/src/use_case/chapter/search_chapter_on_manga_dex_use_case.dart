import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../mixin/sync_chapters_mixin.dart';

class SearchChapterOnMangaDexUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  const SearchChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterRepository = chapterRepository,
        _chapterDao = chapterDao,
        _logBox = logBox;

  Future<Result<Pagination<MangaChapter>>> execute({
    required String? mangaId,
    required SearchChapterParameter parameter,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    try {
      final result = await _chapterRepository.feed(
        mangaId: mangaId,
        parameter: parameter.copyWith(
          includes: [Include.scanlationGroup, ...?parameter.includes],
        ),
      );

      final data = result.data ?? [];

      return Success(
        Pagination(
          data: await sync(
            chapterDao: _chapterDao,
            logBox: _logBox,
            values: [
              for (final e in data)
                MangaChapter.from(data: e).copyWith(mangaId: mangaId),
            ],
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
