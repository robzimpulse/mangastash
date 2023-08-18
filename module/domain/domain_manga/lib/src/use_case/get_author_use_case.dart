import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetAuthorUseCase {
  final AuthorRepository _repository;

  const GetAuthorUseCase({
    required AuthorRepository repository,
  }) : _repository = repository;

  Future<Response<AuthorResponse>> execute({
    required String authorId,
  }) async {
    try {
      final response = await _repository.detail(authorId);
      return Success(response);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
