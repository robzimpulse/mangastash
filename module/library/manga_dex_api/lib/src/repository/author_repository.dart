import '../enums/includes.dart';
import '../model/author/author_response.dart';
import '../service/author_service.dart';

class AuthorRepository {
  final AuthorService _service;

  AuthorRepository({
    required AuthorService service,
  }) : _service = service;

  Future<AuthorResponse> detail(String id, {List<Include>? includes}) async {
    return _service.detail(
      id: id,
      includes: includes?.map((e) => e.rawValue).toList(),
    );
  }
}
