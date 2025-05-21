import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaDao mangaDao,
    required List<Manga> values,
    required LogBox logBox,
  }) async {
    final before = {
      for (final manga in values)
        manga.toDrift: (manga.tags ?? []).map((e) => e.toDrift).toList(),
    };

    final results = await mangaDao.sync(before);

    final after = [
      for (final result in results.entries)
        Manga.fromDrift(result.key, tags: result.value),
    ];

    logBox.log(
      'Insert & Update Manga',
      extra: {
        'before': before.length,
        'after': after.length,
      },
      name: 'Sync Process',
    );

    return after;
  }
}
