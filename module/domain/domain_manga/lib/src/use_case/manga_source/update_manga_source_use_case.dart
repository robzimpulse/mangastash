import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class UpdateMangaSourcesUseCase {
  final SourceService _service;

  UpdateMangaSourcesUseCase({required SourceService service})
      : _service = service;

  Future<void> execute({required List<MangaSource> data}) async {
    await Future.wait(data.map((e) => _service.update(e)));
  }
}