import '../enums/includes.dart';
import '../model/chapter/chapter_response.dart';
import '../model/chapter/search_chapter_parameter.dart';
import '../model/chapter/search_chapter_response.dart';
import '../service/chapter_service.dart';
import '../service/manga_service.dart';

class ChapterRepository {
  final ChapterService _chapterService;
  final MangaService _mangaService;

  const ChapterRepository({
    required MangaService mangaService,
    required ChapterService chapterService,
  })  : _chapterService = chapterService,
        _mangaService = mangaService;

  Future<ChapterResponse> detail(String id, {List<Include>? includes}) {
    return _chapterService.detail(
      id: id,
      includes: includes?.map((e) => e.rawValue).toList(),
    );
  }

  Future<SearchChapterResponse> feed({
    required String mangaId,
    SearchChapterParameter? parameter,
  }) {
    return _mangaService.feed(
      id: mangaId,
      limit: parameter?.limit,
      offset: parameter?.offset,
      translatedLanguage:
          parameter?.translatedLanguage?.map((e) => e.rawValue).toList(),
      originalLanguage:
          parameter?.originalLanguage?.map((e) => e.rawValue).toList(),
      excludedOriginalLanguage:
          parameter?.excludedOriginalLanguages?.map((e) => e.rawValue).toList(),
      excludedGroups: parameter?.excludedGroups,
      excludedUploaders: parameter?.excludedUploaders,
      contentRating: parameter?.contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: parameter?.createdAtSince,
      updatedAtSince: parameter?.updatedAtSince,
      publishedAtSince: parameter?.publishedAtSince,
      includes: parameter?.includes?.map((e) => e.rawValue).toList(),
      orders: parameter?.orders?.map(
        (key, value) => MapEntry(key.rawValue, value.rawValue),
      ),
      // TODO: include this param
      // includeEmptyPages: 1,
      // includeExternalUrl: 1,
      // includeFuturePublishAt: 1,
      // includeFutureUpdates: '1',
    );
  }
}
