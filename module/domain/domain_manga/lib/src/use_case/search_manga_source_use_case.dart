import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class SearchMangaSourcesUseCase {
  final SourceService _service;

  SearchMangaSourcesUseCase({required SourceService service})
      : _service = service;

  Future<Result<Pagination<MangaSource>>> execute({
    String? name,
    String? url,
    int? offset,
  }) async {
    return _service.search(
      name: name,
      url: url,
      offset: offset,
    );
  }
}
