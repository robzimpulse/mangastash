import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';
import '../models/chapter/chapter_data.dart';

part 'chapter_service.g.dart';

@RestApi()
abstract class ChapterService {
  factory ChapterService(MangaDexDio dio, {String baseUrl}) = _ChapterService;

  @GET('/chapter')
  Future<ChapterData> chapter({
    @Query('manga') String mangaId,
    @Query('ids') List<String>? ids,
    @Query('title') String? title,
    @Query('groups') List<String>? groups,
    @Query('uploader') String? uploader,
    @Query('volume') String? volume,
    @Query('chapter') String? chapter,
    @Query('translatedLanguage') List<String>? translatedLanguage,
    @Query('originalLanguage') List<String>? originalLanguage,
    @Query('excludedOriginalLanguage') List<String>? excludedOriginalLanguage,
    @Query('contentRating') List<String>? contentRating,
    @Query('createdAtSince') String? createdAtSince,
    @Query('updatedAtSince') String? updatedAtSince,
    @Query('publishedAtSince') String? publishedAtSince,
    @Query('includes') String? includes,
    @Query('orders') Map<String, String>? orders,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });
}