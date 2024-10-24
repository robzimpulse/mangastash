import '../enums/content_rating.dart';
import '../enums/includes.dart';
import '../enums/language_codes.dart';
import '../enums/order_enums.dart';
import '../model/chapter/chapter_response.dart';
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
    List<String>? ids,
    String? title,
    List<String>? groups,
    String? uploader,
    String? volume,
    String? chapter,
    List<LanguageCodes>? translatedLanguage,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguage,
    List<ContentRating>? contentRating,
    String? createdAtSince,
    String? updatedAtSince,
    String? publishedAtSince,
    List<Include>? includes,
    Map<ChapterOrders, OrderDirections>? orders,
    int? limit,
    int? offset,
  }) {
    return _mangaService.feed(
      id: mangaId,
      limit: limit,
      offset: offset,
      translatedLanguage: translatedLanguage?.map((e) => e.rawValue).toList(),
      originalLanguage: originalLanguage?.map((e) => e.rawValue).toList(),
      excludedOriginalLanguage:
          excludedOriginalLanguage?.map((e) => e.rawValue).toList(),
      excludedGroups: [],
      excludedUploaders: [],
      contentRating: contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: createdAtSince,
      updatedAtSince: updatedAtSince,
      publishedAtSince: publishedAtSince,
      includes: includes?.map((e) => e.rawValue).toList(),
      orders: orders?.map(
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
