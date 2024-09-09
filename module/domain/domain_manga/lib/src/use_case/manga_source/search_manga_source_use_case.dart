import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class SearchMangaSourcesUseCase {
  final MangaSourceServiceFirebase _service;

  SearchMangaSourcesUseCase({required MangaSourceServiceFirebase service})
      : _service = service;

  Future<Result<Pagination<MangaSource>>> execute({
    MangaSourceEnum? name,
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
