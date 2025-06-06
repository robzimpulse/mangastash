import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required ChapterDao chapterDao,
    required List<MangaChapter> values,
    required LogBox logBox,
  }) async {
    final success = <MangaChapter>[];
    final failed = <MangaChapter>[];
    final changed = <(MangaChapter, MangaChapter)>[];

    final chapters = await chapterDao.search(
      mangaIds: [...values.map((e) => e.mangaId).nonNulls],
    );

    for (final before in values) {
      final byId = before.id?.let(
        (id) => chapters.firstWhereOrNull((e) => e.chapter?.id == id),
      );

      final byWebUrl = before.webUrl?.let(
        (url) => chapters.firstWhereOrNull(
          (e) => e.chapter?.webUrl == url,
        ),
      );

      final existing = (byId ?? byWebUrl).let(
        (e) => e.chapter?.let(
          (chapter) => MangaChapter.fromDrift(
            chapter,
            images: e.images,
          ),
        ),
      );

      final result = await chapterDao.add(
        value: before.merge(other: existing).toDrift,
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
