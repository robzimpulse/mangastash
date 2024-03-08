import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetCoverArtUseCase {
  final CoverRepository _repository;

  const GetCoverArtUseCase({
    required CoverRepository repository,
  }) : _repository = repository;

  Future<Result<String>> execute({
    required String mangaId,
    required String coverId,
  }) async {
    try {
      final response = await _repository.detail(coverId);
      final filename = response.data?.attributes?.fileName;
      if (filename == null) return Success('');
      return Success(_repository.coverUrl(mangaId, filename));
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
