import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

class GetNeighbourChapterUseCase {
  final ChapterDao _chapterDao;

  GetNeighbourChapterUseCase({required ChapterDao chapterDao})
    : _chapterDao = chapterDao;

  Future<List<Chapter>> execute({
    required String chapterId,
    required int count,
    NextChapterDirection direction = NextChapterDirection.next,
  }) async {
    final result = await _chapterDao.getNeighbourChapters(
      chapterId: chapterId,
      count: count,
      direction: direction,
    );

    return result.map(Chapter.fromDatabase).nonNulls.toList();
  }
}
