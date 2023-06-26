import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';
import '../models/common/base_url.dart';

part 'at_home_service.g.dart';

@RestApi()
abstract class AtHomeService {
  factory AtHomeService(MangaDexDio dio, {String baseUrl}) = _AtHomeService;

  @GET('/at-home/server/{id}')
  Future<BaseUrl> url(@Path() String id);
}