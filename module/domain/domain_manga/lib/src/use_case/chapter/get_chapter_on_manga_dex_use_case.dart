import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetChapterOnMangaDexUseCase {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;

  const GetChapterOnMangaDexUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    try {
      final response = await Future.wait([
        _chapterRepository.detail(chapterId, includes: [Include.manga]),
        _atHomeRepository.url(chapterId),
      ]);

      final chapter = response[0] as ChapterResponse;
      final atHome = response[1] as AtHomeResponse;

      return Success(
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
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
