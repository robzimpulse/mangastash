import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

import '../prefetch/listen_prefetch_chapter_config.dart';

class GetNeighbourChapterUseCase {
  final ChapterDao _chapterDao;

  GetNeighbourChapterUseCase({required ChapterDao chapterDao})
    : _chapterDao = chapterDao;

  Future<List<Chapter>> execute({
    required String chapterId,
    required int count,
    NextChapterDirection direction = NextChapterDirection.next,
  }) async {
    if (count < 1) return [];

    final result = await _chapterDao.getNeighbourChapters(
      chapterId: chapterId,
      count: count,
      direction: direction,
    );

    return result.map(Chapter.fromDatabase).nonNulls.toList();
  }
}
