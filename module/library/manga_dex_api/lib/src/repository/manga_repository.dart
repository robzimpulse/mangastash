import '../enums/content_rating.dart';
import '../enums/includes.dart';
import '../enums/language_codes.dart';
import '../enums/manga_status.dart';
import '../enums/order_enums.dart';
import '../enums/publication_demographic.dart';
import '../enums/tag_modes.dart';
import '../model/manga/manga_response.dart';
import '../model/manga/search_manga_response.dart';
import '../model/tag/tag_response.dart';
import '../service/manga_service.dart';

class MangaRepository {
  final MangaService _service;

  const MangaRepository({
    required MangaService service,
  }) : _service = service;

  Future<SearchMangaResponse> search({
    String? title,
    int? limit,
    int? offset,
    List<String>? authors,
    List<String>? artists,
    int? year,
    List<String>? includedTags,
    TagsMode? includedTagsMode,
    List<String>? excludedTags,
    TagsMode? excludedTagsMode,
    List<MangaStatus>? status,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguages,
    List<LanguageCodes>? availableTranslatedLanguage,
    List<PublicDemographic>? publicationDemographic,
    List<String>? ids,
    List<ContentRating>? contentRating,
    String? createdAtSince,
    String? updatedAtSince,
    List<Include>? includes,
    String? group,
    Map<SearchOrders, OrderDirections>? orders,
  }) {
    return _service.search(
      title: title,
      limit: limit,
      offset: offset,
      authors: authors,
      artists: artists,
      year: year,
      includedTags: includedTags,
      includedTagsMode: includedTagsMode?.rawValue,
      excludedTags: excludedTags,
      excludedTagsMode: excludedTagsMode?.rawValue,
      status: status?.map((e) => e.rawValue).toList(),
      originalLanguage: originalLanguage?.map((e) => e.rawValue).toList(),
      excludedOriginalLanguages:
          excludedOriginalLanguages?.map((e) => e.rawValue).toList(),
      availableTranslatedLanguage:
          availableTranslatedLanguage?.map((e) => e.rawValue).toList(),
      publicationDemographic:
          publicationDemographic?.map((e) => e.rawValue).toList(),
      ids: ids,
      contentRating: contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: createdAtSince,
      updatedAtSince: updatedAtSince,
      includes: includes?.map((e) => e.rawValue).toList(),
      group: group,
      orders: orders?.map(
        (key, value) => MapEntry(key.rawValue, value.rawValue),
      ),
    );
  }

  Future<TagResponse> tags() {
    return _service.tags();
  }

  Future<MangaResponse> detail({required String id, List<Include>? includes}) {
    return _service.detail(
      id: id,
      includes: includes?.map((e) => e.rawValue).toList(),
    );
  }
}
