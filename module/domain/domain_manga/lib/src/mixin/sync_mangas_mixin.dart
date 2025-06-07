import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
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

    final mangas = await mangaDao.search(
      ids: [...values.map((e) => e.id).nonNulls],
      webUrls: [...values.map((e) => e.webUrl).nonNulls],
    );

    for (final before in values) {
      final byId = before.id?.let(
        (id) => mangas.firstWhereOrNull(
          (e) => e.manga?.id == id,
        ),
      );

      final byWebUrl = before.webUrl?.let(
        (url) => mangas.firstWhereOrNull(
          (e) => e.manga?.webUrl == url,
        ),
      );

      final existing = Manga.fromDatabase(byId ?? byWebUrl);

      final result = await mangaDao.add(
        value: before.merge(other: existing).toDrift,
        tags: [
          ...?before.merge(other: existing).tags?.map((e) => e.name).nonNulls,
        ],
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
