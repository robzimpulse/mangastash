import 'package:retrofit/http.dart';

import '../client/manga_dex_dio.dart';

part 'search_service.g.dart';

@RestApi()
abstract class SearchService {
  factory SearchService(MangaDexDio dio, {String baseUrl}) = _SearchService;

}