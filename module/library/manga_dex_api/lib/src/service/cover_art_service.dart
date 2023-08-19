import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../model/cover_art/cover_art_response.dart';

part 'cover_art_service.g.dart';

@RestApi()
abstract class CoverArtService {
  factory CoverArtService(Dio dio, {String baseUrl}) = _CoverArtService;

  @GET('/cover/{id}')
  Future<CoverArtResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}
