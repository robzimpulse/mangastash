import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';
import '../model/author/author_response.dart';

part 'author_service.g.dart';

@RestApi()
abstract class AuthorService {
  factory AuthorService(MangaDexDio dio, {String baseUrl}) = _AuthorService;

  @GET('/author')
  Future<AuthorResponse> search({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('ids[]') List<String>? ids,
    @Query('name') String? name,
    @Query('includes[]') List<String>? includes,
    @Query('orders') Map<String, String>? orders,
  });
}