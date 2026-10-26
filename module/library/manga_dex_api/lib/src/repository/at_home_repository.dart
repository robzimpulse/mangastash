import '../model/at_home/at_home_response.dart';
import '../service/at_home_service.dart';

class AtHomeRepository {
  final AtHomeService _service;

  const AtHomeRepository({
    required this._service,
  });

  Future<AtHomeResponse> url(String id) {
    return _service.url(id);
  }
}
