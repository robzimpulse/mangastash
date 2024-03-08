import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetChapterUseCase {
  final ChapterRepository _chapterRepository;
  final AtHomeRepository _atHomeRepository;

  const GetChapterUseCase({
    required ChapterRepository chapterRepository,
    required AtHomeRepository atHomeRepository,
  })  : _chapterRepository = chapterRepository,
        _atHomeRepository = atHomeRepository;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
  }) async {
    try {
      final response = await _chapterRepository.detail(chapterId);
      final result = await _atHomeRepository.url(chapterId);
      final data = response.data;
      if (data == null) throw Exception('Chapter not found');
      return Success(
        MangaChapter.from(
          data,
          images: result.images,
          imagesDataSaver: result.imagesDataSaver,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
