import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../dio/mangadex_dio.dart';
import '../model/author/author_response.dart';

part 'author_service.g.dart';

@RestApi()
abstract class AuthorService {
  factory AuthorService(MangaDexDio dio, {String baseUrl}) = _AuthorService;

  @GET('/author/{id}')
  Future<AuthorResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}
