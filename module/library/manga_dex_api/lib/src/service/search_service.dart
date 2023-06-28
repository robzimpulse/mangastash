import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';
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
    @Query('authors[]') List<String>? authors,
    @Query('artists[]') List<String>? artists,
    @Query('year') int? year,
    @Query('includedTags[]') List<String>? includedTags,
    @Query('includedTagsMode[]') String? includedTagsMode,
    @Query('excludedTags[]') List<String>? excludedTags,
    @Query('excludedTagsMode') String? excludedTagsMode,
    @Query('status[]') List<String>? status,
    @Query('originalLanguage[]') List<String>? originalLanguage,
    @Query('excludedOriginalLanguages[]') List<String>? excludedOriginalLanguages,
    @Query('availableTranslatedLanguage[]') List<String>? availableTranslatedLanguage,
    @Query('publicationDemographic[]') List<String>? publicationDemographic,
    @Query('ids[]') List<String>? ids,
    @Query('contentRating[]') List<String>? contentRating,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('includes[]') List<String>? includes,
    @Query('group') String? group,
    @Query('orders') Map<String, String>? orders,
  });
}