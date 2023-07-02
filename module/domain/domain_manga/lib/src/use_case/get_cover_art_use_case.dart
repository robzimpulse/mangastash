import 'package:manga_dex_api/manga_dex_api.dart';

class GetCoverArtUseCase {
  final CoverRepository _repository;

  const GetCoverArtUseCase({
    required CoverRepository repository,
  }) : _repository = repository;

  String execute({required String mangaId, required String filename}) {
    return _repository.coverUrl(mangaId, filename);
  }
}
