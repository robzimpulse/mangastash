import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

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
        tags: before.tagsName,
      );

      final after = result.manga?.let(
        (e) => Manga.fromDrift(
          e,
          tags: result.tags,
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
