import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class MangaService {
  Future<void> add(Manga value);
  Future<void> update(Manga value);
  Future<bool> exists(String id);
  Future<Result<List<Manga>>> list();
  Future<Result<Pagination<Manga>>> search({
    String? title,
    String? author,
    String? status,
    String? description,
    int limit,
    int? offset,
  });
}