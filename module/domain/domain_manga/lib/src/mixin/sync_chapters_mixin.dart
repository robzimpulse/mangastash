import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required ChapterDao chapterDao,
    required List<MangaChapter> values,
    required LogBox logBox,
  }) async {
    final success = <MangaChapter>[];
    final failed = <MangaChapter>[];
    final changed = <(MangaChapter, MangaChapter)>[];

    for (final before in values) {
      final result = await chapterDao.add(
        value: before.toDrift,
        images: [...?before.images],
      );

      final after = result.chapter?.let(
        (e) => MangaChapter.fromDrift(
          e,
          images: result.images,
        ),
      );

      if (after == null) {
        failed.add(before);
        continue;
      }

      if (after.id != before.id) {
        changed.add((before, after));
      }

      success.add(after);
    }

    logBox.log(
      'Insert & Update Chapter',
      extra: {
        'before count': values.length,
        'after count': success.length,
        'inconsistent key count': changed.length,
        'inconsistent key': {
          for (final (before, after) in changed) before.id: after.id,
        },
      },
      name: 'Sync Process',
    );

    return success;
  }
}
