import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetChapterUseCase {
  final ChapterRepository _repository;

  const GetChapterUseCase({
    required ChapterRepository repository,
  }) : _repository = repository;

  Future<Response<MangaChapter>> execute({
    required String chapterId,
  }) async {
    try {
      final response = await _repository.detail(chapterId);
      final data = response.data;
      if (data == null) throw Exception('Chapter not found');
      return Success(MangaChapter.from(data));
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
