import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetListMangaSourcesUseCase {
  final MangaSourceServiceFirebase _service;

  GetListMangaSourcesUseCase({required MangaSourceServiceFirebase service})
      : _service = service;

  Future<Result<List<MangaSource>>> execute() async {
    return _service.list();
  }
}
