import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchAuthorUseCase {
  final AuthorRepository _repository;

  const SearchAuthorUseCase({
    required AuthorRepository repository,
  }) : _repository = repository;

  Future<Response<AuthorResponse>> execute({
    String? name,
    int? limit,
    int? offset,
    List<String>? includes,
    Map<AuthorOrders, OrderDirections>? orders,
  }) async {
    try {
      final result = await _repository.search(
        name: name,
        limit: limit,
        offset: offset,
        includes: includes,
        orders: orders,
      );
      return Success(result);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}