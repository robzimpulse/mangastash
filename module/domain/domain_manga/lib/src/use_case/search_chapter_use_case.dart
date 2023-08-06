import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchChapterUseCase {
  final ChapterRepository _repository;

  const SearchChapterUseCase({
    required ChapterRepository repository,
  }) : _repository = repository;

  Future<Response<SearchChapterResponse>> execute({
    required SearchChapterParameter parameter,
  }) async {
    try {
      final result = await _repository.search(
        mangaId: parameter.mangaId ?? '',
        ids: parameter.ids,
        title: parameter.title,
        groups: parameter.groups,
        uploader: parameter.uploader,
        volume: parameter.volume,
        chapter: parameter.chapter,
        translatedLanguage: parameter.translatedLanguage,
        originalLanguage: parameter.originalLanguage,
        excludedOriginalLanguage: parameter.excludedOriginalLanguage,
        contentRating: parameter.contentRating,
        createdAtSince: parameter.createdAtSince,
        updatedAtSince: parameter.updatedAtSince,
        publishedAtSince: parameter.publishedAtSince,
        includes: parameter.includes,
        orders: parameter.orders,
        limit: parameter.limit,
        offset: parameter.offset,
      );

      return Success(result);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}