import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetAllChapterUseCase {
  final ChapterRepository _repository;

  const GetAllChapterUseCase({
    required ChapterRepository repository,
  }) : _repository = repository;

  Future<Response<List<ChapterData>>> execute({
    required SearchChapterParameter parameter,
  }) async {
    try {
      var total = 0;
      var param = parameter.copyWith(limit: 100);
      List<ChapterData> chapters = [];

      do {
        final result = await _repository.search(
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

        final data = result.data ?? [];
        total = result.total ?? 0;
        chapters.addAll(data);

      } while (chapters.length < total);

      return Success(chapters);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}