import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../mixin/sync_chapter_mixin.dart';

class GetChapterOnMangaDexUseCase with SyncChapterMixin {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;

  const GetChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository,
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

      return Success(
        await sync(
          mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
          value: MangaChapter(
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
        ),
      );
    } catch (e) {
      return Error(e);
    }
  }
}
