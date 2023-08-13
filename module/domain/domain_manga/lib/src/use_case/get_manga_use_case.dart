import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaUseCase {
  final MangaRepository _repository;

  const GetMangaUseCase({
    required MangaRepository repository,
  }) : _repository = repository;

  Future<Response<Manga>> execute(
    String id, {
    List<String>? includes,
  }) async {
    try {
      final result = await _repository.detail(id);
      final data = result.data;
      if (data == null) throw Exception('Manga not found');
      return Success(Manga.from(data));
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
