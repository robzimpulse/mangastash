import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class GetListTagsUseCase {
  final MangaTagService _service;

  GetListTagsUseCase({required MangaTagService service})
      : _service = service;

  Future<Result<List<MangaTag>>> execute() async {
    return _service.list();
  }
}