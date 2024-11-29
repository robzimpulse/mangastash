import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';

import '../model/at_home/at_home_response.dart';

part 'at_home_service.g.dart';

@RestApi(
  baseUrl: 'https://api.mangadex.org',
  parser: Parser.FlutterCompute,
)
abstract class AtHomeService {
  factory AtHomeService(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AtHomeService;

  @GET('/at-home/server/{id}')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
  Future<AtHomeResponse> url(@Path() String id);
}
