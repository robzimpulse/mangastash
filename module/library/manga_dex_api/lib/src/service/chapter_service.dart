import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../dio/mangadex_dio.dart';
import '../model/chapter/chapter_response.dart';
import '../model/chapter/search_chapter_response.dart';

part 'chapter_service.g.dart';

@RestApi()
abstract class ChapterService {
  factory ChapterService(MangaDexDio dio, {String baseUrl}) = _ChapterService;

  @GET('/chapter')
  Future<SearchChapterResponse> search({
    @Query('manga') String? mangaId,
    @Query('ids[]') List<String>? ids,
    @Query('title') String? title,
    @Query('groups[]') List<String>? groups,
    @Query('uploader') String? uploader,
    @Query('volume') String? volume,
    @Query('chapter') String? chapter,
    @Query('translatedLanguage[]') List<String>? translatedLanguage,
    @Query('originalLanguage[]') List<String>? originalLanguage,
    @Query('excludedOriginalLanguage[]') List<String>? excludedOriginalLanguage,
    @Query('contentRating[]') List<String>? contentRating,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('publishedAtSince') String? publishedAtSince,
    @Query('includes[]') List<String>? includes,
    @Query('order') Map<String, String>? orders,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/chapter/{id}')
  Future<ChapterResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}
