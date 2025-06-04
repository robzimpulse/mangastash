import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../mixin/sync_chapters_mixin.dart';

class GetChapterOnMangaDexUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;

  final ChapterDao _chapterDao;
  final LogBox _logBox;

  const GetChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository,
        _chapterDao = chapterDao,
        _logBox = logBox;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    final raw = await _chapterDao.search(ids: [chapterId]);
    final result = raw.firstOrNull.let(
      (e) => e.chapter?.let(
        (d) => MangaChapter.fromDrift(d, images: e.images),
      ),
    );

    if (result != null && result.images?.isNotEmpty == true) {
      return Success(result);
    }

    try {
      final response = await Future.wait([
        _chapterRepository.detail(chapterId, includes: [Include.manga]),
        _atHomeRepository.url(chapterId),
      ]);

      final chapter = response[0] as ChapterResponse;
      final atHome = response[1] as AtHomeResponse;

      final chapters = await sync(
        chapterDao: _chapterDao,
        logBox: _logBox,
        values: [
          MangaChapter(
            id: chapter.data?.id,
            title: chapter.data?.attributes?.title,
            chapter: chapter.data?.attributes?.chapter,
            volume: chapter.data?.attributes?.volume,
            images: atHome.images,
            translatedLanguage: chapter.data?.attributes?.translatedLanguage,
            mangaId: mangaId,
          ),
        ],
      );

      final value = chapters.firstOrNull;

      if (value == null) {
        return Error('Empty Sync Chapter');
      }

      return Success(value);
    } catch (e) {
      return Error(e);
    }
  }
}
