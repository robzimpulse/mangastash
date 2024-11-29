import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';

import '../model/chapter/chapter_response.dart';
import '../model/chapter/search_chapter_response.dart';

part 'chapter_service.g.dart';

@RestApi(
  baseUrl: 'https://api.mangadex.org',
  parser: Parser.FlutterCompute,
)
abstract class ChapterService {
  factory ChapterService(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _ChapterService;

  @GET('/chapter')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
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
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
  Future<ChapterResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}
