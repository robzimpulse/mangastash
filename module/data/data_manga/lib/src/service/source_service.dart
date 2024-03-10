import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class SourceService {
  Future<Result<List<MangaSource>>> list();
  Future<Result<MangaSource>> get(String id);
}
