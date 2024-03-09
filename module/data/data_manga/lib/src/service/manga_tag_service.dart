import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

abstract class MangaTagService {
  Future<Result<List<MangaTag>>> list();
}