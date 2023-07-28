import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaUseCase {
  final MangaRepository _repository;

  const GetMangaUseCase({
    required MangaRepository repository,
  }) : _repository = repository;

  Future<Response<SearchData>> execute(
    String id, {
    List<String>? includes,
  }) async {
    try {
      final result = await _repository.detail(id);
      return Success(result);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
