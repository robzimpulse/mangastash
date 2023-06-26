import '../models/common/base_url.dart';
import '../service/at_home_service.dart';

class AtHomeRepository {
  final AtHomeService _service;

  AtHomeRepository({
    required AtHomeService service,
  }) : _service = service;

  Future<BaseUrl> url(String id) {
    return _service.url(id);
  }
}