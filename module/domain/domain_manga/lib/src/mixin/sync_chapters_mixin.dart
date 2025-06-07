import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncChaptersMixin {
  Future<List<Chapter>> sync({
    required ChapterDao chapterDao,
    required List<Chapter> values,
    required LogBox logBox,
  }) async {
    final success = <Chapter>[];
    final failed = <Chapter>[];
    final changed = <(Chapter, Chapter)>[];

    final chapters = await chapterDao.search(
      ids: [...values.map((e) => e.id).nonNulls],
      webUrls: [...values.map((e) => e.webUrl).nonNulls],
    );

    for (final before in values) {
      final byId = before.id?.let(
        (id) => chapters.firstWhereOrNull(
          (e) => e.chapter?.id == id,
        ),
      );

      final byWebUrl = before.webUrl?.let(
        (url) => chapters.firstWhereOrNull(
          (e) => e.chapter?.webUrl == url,
        ),
      );

      final existing = Chapter.fromDatabase(byId ?? byWebUrl);

      final result = await chapterDao.add(
        value: before.merge(other: existing).toDrift,
        images: [...?before.merge(other: existing).images],
      );

      final after = result.chapter?.let(
        (e) => Chapter.fromDrift(
          e,
          images: result.images,
        ),
      );

      if (after == null) {
        failed.add(before);
        continue;
      }

      if (before.id != null && after.id != before.id) {
        changed.add((before, after));
      }

      success.add(after);
    }

    logBox.log(
      'Insert & Update Chapter',
      extra: {
        'existing count': chapters.length,
        'before count': values.length,
        'after count': success.length,
        'failed count': failed.length,
        'changed id count': changed.length,
      },
      name: 'Sync Process',
    );

    return success;
  }
}
