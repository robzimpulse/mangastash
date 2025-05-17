import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../mixin/sync_chapters_mixin.dart';

class GetChapterOnMangaDexUseCase with SyncChaptersMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  const GetChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository,
        _chapterDao = chapterDao,
        _logBox = logBox,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    final raw = await _mangaChapterServiceFirebase.get(id: chapterId);
    final result = raw?.let((e) => MangaChapter.fromFirebaseService(e));

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
        mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
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
            mangaTitle: chapter.data?.relationships
                ?.whereType<Relationship<MangaDataAttributes>>()
                .firstOrNull
                ?.attributes
                ?.title
                ?.en,
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
