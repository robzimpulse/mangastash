import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class SourceService {
  Future<void> add(MangaSource value);
  Future<void> update(MangaSource value);
  Future<Result<List<MangaSource>>> list();
  Future<Result<MangaSource>> get(String id);
  Future<Result<Pagination<MangaSource>>> search({
    String? name,
    String? url,
    int limit,
    int? offset,
  });
}
