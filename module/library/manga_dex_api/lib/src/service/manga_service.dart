import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../dio/mangadex_dio.dart';
import '../model/chapter/search_chapter_response.dart';
import '../model/manga/manga_response.dart';
import '../model/manga/search_manga_response.dart';
import '../model/tag/tag_response.dart';

part 'manga_service.g.dart';

@RestApi()
abstract class MangaService {
  factory MangaService(MangaDexDio dio, {String baseUrl}) = _MangaService;

  @GET('/manga')
  Future<SearchMangaResponse> search({
    @Query('title') String? title,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('authors[]') List<String>? authors,
    @Query('artists[]') List<String>? artists,
    @Query('year') int? year,
    @Query('includedTags[]') List<String>? includedTags,
    @Query('includedTagsMode') String? includedTagsMode,
    @Query('excludedTags[]') List<String>? excludedTags,
    @Query('excludedTagsMode') String? excludedTagsMode,
    @Query('status[]') List<String>? status,
    @Query('originalLanguage[]') List<String>? originalLanguage,
    @Query('excludedOriginalLanguages[]')
    List<String>? excludedOriginalLanguages,
    @Query('availableTranslatedLanguage[]')
    List<String>? availableTranslatedLanguage,
    @Query('publicationDemographic[]') List<String>? publicationDemographic,
    @Query('ids[]') List<String>? ids,
    @Query('contentRating[]') List<String>? contentRating,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('includes[]') List<String>? includes,
    @Query('group') String? group,
    @Query('order') Map<String, String>? orders,
  });

  @GET('/manga/tag')
  Future<TagResponse> tags();

  @GET('/manga/{id}')
  Future<MangaResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });

  @GET('/manga/{id}/feed')
  Future<SearchChapterResponse> feed({
    @Path('id') String? id,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('translatedLanguage[]') List<String>? translatedLanguage,
    @Query('originalLanguage[]') List<String>? originalLanguage,
    @Query('excludedOriginalLanguage[]') List<String>? excludedOriginalLanguage,
    @Query('contentRating[]') List<String>? contentRating,
    @Query('excludedGroups[]') List<String>? excludedGroups,
    @Query('excludedUploaders[]') List<String>? excludedUploaders,
    @Query('includeFutureUpdates') String? includeFutureUpdates,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('publishedAtSince') String? publishedAtSince,
    @Query('order') Map<String, String>? orders,
    @Query('includes[]') List<String>? includes,
    @Query('includeEmptyPages') int? includeEmptyPages,
    @Query('includeFuturePublishAt') int? includeFuturePublishAt,
    @Query('includeExternalUrl') int? includeExternalUrl,
  });
}
