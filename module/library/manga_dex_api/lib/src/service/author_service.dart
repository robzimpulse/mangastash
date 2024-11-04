import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:retrofit/http.dart';

import '../model/author/author_response.dart';

part 'author_service.g.dart';

@RestApi(
  baseUrl: 'https://api.mangadex.org',
  parser: Parser.FlutterCompute,
)
abstract class AuthorService {
  factory AuthorService(Dio dio, {String baseUrl}) = _AuthorService;

  @GET('/author/{id}')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
  Future<AuthorResponse> detail({
    @Path('id') String? id,
    @Query('includes[]') List<String>? includes,
  });
}