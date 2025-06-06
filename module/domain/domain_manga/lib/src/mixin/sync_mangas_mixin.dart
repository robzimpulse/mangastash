import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaDao mangaDao,
    required List<Manga> values,
    required LogBox logBox,
  }) async {
    final success = <Manga>[];
    final failed = <Manga>[];
    final changed = <(Manga, Manga)>[];

    for (final before in values) {
      final result = await mangaDao.add(
        value: before.toDrift,
        tags: [...?before.tags?.map((e) => e.name).nonNulls],
      );

      final after = Manga.fromDatabase(result);

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
      'Insert & Update Manga',
      extra: {
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
