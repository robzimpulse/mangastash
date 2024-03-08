import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetAllMangaSourcesUseCase {
  final SourceService _service;

  GetAllMangaSourcesUseCase({required SourceService service})
      : _service = service;

  Future<List<MangaSource>> execute() async {
    return _service.list();
  }
}
