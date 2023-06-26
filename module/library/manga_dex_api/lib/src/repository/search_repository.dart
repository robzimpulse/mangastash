import '../enums/content_rating.dart';
import '../enums/language_codes.dart';
import '../enums/manga_status.dart';
import '../enums/order_enums.dart';
import '../enums/publication_demographic.dart';
import '../enums/tag_modes.dart';
import '../models/search/search.dart';
import '../service/search_service.dart';

class SearchRepository {
  final SearchService _searchService;

  SearchRepository({
    required SearchService searchService,
  }) : _searchService = searchService;
  
  Future<Search> search({
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
    List<String>? includes,
    String? group,
    Map<SearchOrders, OrderDirections>? orders,
  }) {
    return _searchService.search(
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
      excludedOriginalLanguages: excludedOriginalLanguages?.map((e) => e.rawValue).toList(),
      availableTranslatedLanguage: availableTranslatedLanguage?.map((e) => e.rawValue).toList(),
      publicationDemographic: publicationDemographic?.map((e) => e.rawValue).toList(),
      ids: ids,
      contentRating: contentRating?.map((e) => e.rawValue).toList(),
      createdAtSince: createdAtSince,
      updatedAtSince: updatedAtSince,
      includes: includes,
      group: group,
      orders: orders?.map((key, value) => MapEntry(key.rawValue, value.rawValue)),
    );
  }
}