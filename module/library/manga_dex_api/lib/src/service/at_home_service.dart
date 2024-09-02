import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../dio/mangadex_dio.dart';
import '../model/at_home/at_home_response.dart';

part 'at_home_service.g.dart';

@RestApi()
abstract class AtHomeService {
  factory AtHomeService(MangaDexDio dio, {String baseUrl}) = _AtHomeService;

  @GET('/at-home/server/{id}')
  Future<AtHomeResponse> url(@Path() String id);
}
