import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';
import '../enums/content_rating.dart';
import '../enums/language_codes.dart';
import '../enums/manga_status.dart';
import '../enums/order_enums.dart';
import '../enums/publication_demographic.dart';
import '../enums/tag_modes.dart';
import '../models/search/search.dart';

part 'search_service.g.dart';

@RestApi()
abstract class SearchService {
  factory SearchService(MangaDexDio dio, {String baseUrl}) = _SearchService;

  @GET('/manga')
  Future<Search> search({
    @Query('title') String? title,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('authors') List<String>? authors,
    @Query('artists') List<String>? artists,
    @Query('year') int? year,
    @Query('includedTags') List<String>? includedTags,
    @Query('includedTagsMode') TagsMode? includedTagsMode,
    @Query('excludedTags') List<String>? excludedTags,
    @Query('excludedTagsMode') TagsMode? excludedTagsMode,
    @Query('status') List<MangaStatus>? status,
    @Query('originalLanguage') List<LanguageCodes>? originalLanguage,
    @Query('excludedOriginalLanguages') List<LanguageCodes>? excludedOriginalLanguages,
    @Query('availableTranslatedLanguage') List<LanguageCodes>? availableTranslatedLanguage,
    @Query('publicationDemographic') List<PublicDemographic>? publicationDemographic,
    @Query('ids') List<String>? ids,
    @Query('contentRating') List<ContentRating>? contentRating,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('includes') List<String>? includes,
    @Query('group') String? group,
    @Query('orders') Map<SearchOrders, OrderDirections>? orders,
    @Query('hasAvailableChapters') bool? hasAvailableChapters,
  });
}