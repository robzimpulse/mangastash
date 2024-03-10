import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class MangaTagService {
  Future<void> add(MangaTag value);
  Future<void> update(MangaTag value);
  Future<Result<List<MangaTag>>> list();
  Future<Result<Pagination<MangaTag>>> search({
    String? name,
    int limit,
    int? offset,
  });
}