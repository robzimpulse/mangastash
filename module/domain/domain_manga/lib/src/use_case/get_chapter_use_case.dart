import 'package:core_network/core_network.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetChapterUseCase {
  final ChapterRepository _repository;

  const GetChapterUseCase({
    required ChapterRepository repository,
  }) : _repository = repository;

  Future<Response<ChapterResponse>> execute({
    required String authorId,
  }) async {
    try {
      final response = await _repository.detail(authorId);
      return Success(response);
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
