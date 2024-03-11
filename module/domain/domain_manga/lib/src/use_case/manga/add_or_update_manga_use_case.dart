import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class AddOrUpdateMangaUseCase {
  final MangaService _service;

  AddOrUpdateMangaUseCase({required MangaService service})
      : _service = service;

  Future<void> execute({required List<Manga> data}) async {
    await Future.wait(data.map((e) => _process(e)));
  }

  Future<void> _process(Manga data) async {
    final id = data.id;
    if (id == null) return;
    final isExists = await _service.exists(id);

    if (isExists) {
      await _service.update(data);
    } else {
      await _service.add(data);
    }
  }

}