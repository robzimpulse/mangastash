import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../mixin/sync_chapters_mixin.dart';

class UpdateChapterLastReadAtUseCase with SyncChaptersMixin {
  final ChapterDao _chapterDao;
  final LogBox _logBox;

  UpdateChapterLastReadAtUseCase({
    required ChapterDao chapterDao,
    required LogBox logBox,
  })  : _chapterDao = chapterDao,
        _logBox = logBox;

  Future<void> execute({required Chapter chapter}) async {
    await sync(
      dao: _chapterDao,
      logBox: _logBox,
      values: [chapter.copyWith(lastReadAt: DateTime.timestamp())],
    );
  }
}
