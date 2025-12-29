import 'package:collection/collection.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../mixin/sync_chapters_mixin.dart';

class UpdateChapterUseCase with SyncChaptersMixin {
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  UpdateChapterUseCase({required ChapterDao chapterDao, required LogBox logBox})
    : _chapterDao = chapterDao,
      _logBox = logBox;

  Future<void> removeImage({
    required String chapterId,
    List<String> imageUrls = const [],
  }) async {
    if (imageUrls.isEmpty) return;

    // TODO: adjust chapter images
    // await _execute(
    //   chapterId: chapterId,
    //   updater: (chapter) async {
    //     final images = chapter.images;
    //     if (images == null || images.isEmpty) return null;
    //     return chapter.copyWith(
    //       images: [...images.whereNot((e) => imageUrls.contains(e))],
    //     );
    //   },
    // );
  }

  Future<void> updateLastRead({required String chapterId}) async {
    await _execute(chapterId: chapterId, updater: (chapter) async {
      return chapter.copyWith(lastReadAt: DateTime.now());
    });
  }

  Future<void> _execute({
    required String chapterId,
    required Future<Chapter?> Function(Chapter chapter) updater,
  }) async {
    final raw = await _chapterDao.search(ids: [chapterId]);
    final chapter = raw.firstOrNull.let(
      (e) => e.chapter?.let((d) => Chapter.fromDrift(d, images: e.images)),
    );
    if (chapter == null) return;
    await sync(
      dao: _chapterDao,
      values: [
        ...[await updater(chapter)].nonNulls,
      ],
      logBox: _logBox,
    );
  }
}
