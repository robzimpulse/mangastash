import 'dart:math';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

import '../prefetch/listen_prefetch_chapter_config.dart';

class GetNeighbourChapterUseCase {
  final ChapterDao _chapterDao;
  final ListenPrefetchChapterConfig _listenPrefetchChapterConfig;

  GetNeighbourChapterUseCase({
    required ChapterDao chapterDao,
    required ListenPrefetchChapterConfig listenPrefetchChapterConfig,
  }) : _chapterDao = chapterDao,
       _listenPrefetchChapterConfig = listenPrefetchChapterConfig;

  Future<List<Chapter>> execute({
    required String chapterId,
    NextChapterDirection direction = NextChapterDirection.next,
  }) async {
    final config = _listenPrefetchChapterConfig;
    final result = await _chapterDao.getNeighbourChapters(
      chapterId: chapterId,
      count: switch (direction) {
        NextChapterDirection.previous => max(
          config.numOfPrefetchedPrevChapter.valueOrNull.or(0),
          1,
        ),
        NextChapterDirection.next => max(
          config.numOfPrefetchedNextChapter.valueOrNull.or(0),
          1,
        ),
      },
      direction: direction,
    );

    return result.map(Chapter.fromDatabase).nonNulls.toList();
  }
}
