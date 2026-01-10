import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../model/cover_art/cover_art_response.dart';

part 'cover_art_service.g.dart';

@RestApi(baseUrl: 'https://api.mangadex.org')
abstract class CoverArtService {
  factory CoverArtService(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _CoverArtService;

  @GET('/cover/{id}')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
  Future<CoverArtResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}
