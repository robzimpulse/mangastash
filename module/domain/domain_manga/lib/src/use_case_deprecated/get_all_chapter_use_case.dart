import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetAllChapterUseCase {
  final ChapterRepository _chapterRepository;

  const GetAllChapterUseCase({
    required ChapterRepository chapterRepository,
  }) : _chapterRepository = chapterRepository;

  Future<Result<List<MangaChapterDeprecated>>> execute({
    required SearchChapterParameterDeprecated parameter,
  }) async {
    try {
      var total = 0;
      var param = parameter.copyWith(limit: 100);
      List<MangaChapterDeprecated> chapters = [];

      do {
        final result = await _chapterRepository.search(
          mangaId: param.mangaId ?? '',
          ids: param.ids,
          title: param.title,
          groups: param.groups,
          uploader: param.uploader,
          volume: param.volume,
          chapter: param.chapter,
          translatedLanguage: param.translatedLanguage,
          originalLanguage: param.originalLanguage,
          excludedOriginalLanguage: param.excludedOriginalLanguage,
          contentRating: param.contentRating,
          createdAtSince: param.createdAtSince,
          updatedAtSince: param.updatedAtSince,
          publishedAtSince: param.publishedAtSince,
          includes: param.includes,
          orders: param.orders,
          limit: param.limit,
          offset: param.offset,
        );

        final promises = result.data?.map(_mapChapter) ?? [];
        final data = await Future.wait(promises);

        total = result.total ?? 0;
        chapters.addAll(data);
      } while (chapters.length < total);

      return Success(chapters);
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<MangaChapterDeprecated> _mapChapter(ChapterData data) async {
    return MangaChapterDeprecated.from(
      data,
      images: const [],
      imagesDataSaver: const [],
    );
  }
}
