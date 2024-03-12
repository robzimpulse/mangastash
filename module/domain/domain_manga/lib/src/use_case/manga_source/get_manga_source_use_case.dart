import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetMangaSourceUseCase {
  final MangaSourceServiceFirebase _service;

  GetMangaSourceUseCase({required MangaSourceServiceFirebase service})
      : _service = service;

  Future<Result<MangaSource>> execute(String id) async {
    return _service.get(id);
  }
}
