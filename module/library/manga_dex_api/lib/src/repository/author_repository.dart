import '../enums/order_enums.dart';
import '../model/author/author_response.dart';
import '../service/author_service.dart';

class AuthorRepository {
  final AuthorService _service;

  AuthorRepository({
    required AuthorService service,
  }) : _service = service;

  Future<AuthorResponse> search({
    String? name,
    int? limit,
    int? offset,
    List<String>? includes,
    Map<AuthorOrders, OrderDirections>? orders,
  }) async {
    return _service.search(
      name: name,
      limit: limit,
      offset: offset,
      includes: includes,
      orders: orders
          ?.map((key, value) => MapEntry(key.rawValue, value.rawValue)),
    );
  }

}