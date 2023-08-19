import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetChapterImageUseCase {
  final AtHomeRepository _repository;

  const GetChapterImageUseCase({
    required AtHomeRepository repository,
  }) : _repository = repository;

  Future<Result<AtHomeResponse>> execute({
    required String chapterId,
  }) async {
    try {
      final response = await _repository.url(chapterId);
      return Success(response);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
