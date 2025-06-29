import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

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

  Future<Result<Pagination<Chapter>>> execute({
    required String mangaId,
    required SearchChapterParameter parameter,
  }) async {
    try {
      final result = await _chapterRepository.feed(
        mangaId: mangaId,
        parameter: parameter.copyWith(
          includes: [Include.scanlationGroup, ...?parameter.includes],
        ),
      );

      final data = result.data ?? [];
      final offset = result.offset?.toInt() ?? 0;
      final limit = result.limit?.toInt() ?? 0;
      final total = result.total?.toInt() ?? 0;

      return Success(
        Pagination(
          data: await sync(
            dao: _chapterDao,
            logBox: _logBox,
            values: [
              for (final e in data)
                Chapter.from(data: e).copyWith(mangaId: mangaId),
            ],
          ),
          offset: offset,
          limit: limit,
          total: total,
          hasNextPage: offset + data.length < total,
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
