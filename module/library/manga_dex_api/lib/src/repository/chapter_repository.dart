import '../enums/content_rating.dart';
import '../enums/language_codes.dart';
import '../enums/order_enums.dart';
import '../models/chapter/chapter_data.dart';
import '../service/chapter_service.dart';

class ChapterRepository {
  final ChapterService _service;

  ChapterRepository({
    required ChapterService service,
  }) : _service = service;

  Future<ChapterData> chapter({
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
    String? includes,
    Map<ChapterOrders, OrderDirections>? orders,
    int? limit,
    int? offset,
  }) {
    return _service.chapter(
      mangaId: mangaId,
      ids: ids,
      title: title,
      groups: groups,
      uploader: uploader,
      volume: volume,
      chapter: chapter,
      translatedLanguage: translatedLanguage?.map((e) => e.rawValue).toList(),
      originalLanguage: originalLanguage?.map((e) => e.rawValue).toList(),
      excludedOriginalLanguage: excludedOriginalLanguage?.map((e) => e.rawValue).toList(),
      contentRating: contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: createdAtSince,
      updatedAtSince: updatedAtSince,
      publishedAtSince: publishedAtSince,
      includes: includes,
      orders: orders?.map((key, value) => MapEntry(key.rawValue, value.rawValue)),
      limit: limit,
      offset: offset,
    );
  }
}
