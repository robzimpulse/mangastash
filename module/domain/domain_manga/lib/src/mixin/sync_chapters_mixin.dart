import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required ChapterDao chapterDao,
    required List<MangaChapter> values,
    required LogBox logBox,
  }) async {
    final before = {
      for (final chapter in values) chapter.toDrift: (chapter.images ?? []),
    };

    final results = await chapterDao.sync(before);

    final after = [
      for (final result in results.entries)
        MangaChapter.fromDrift(result.key, images: result.value),
    ];

    final idsBefore = {...before.keys.map((e) => e.id.valueOrNull).nonNulls};
    final idsAfter = {...after.map((e) => e.id).nonNulls};
    final idsDifference = idsBefore.intersection(idsAfter);

    logBox.log(
      'Insert & Update Chapter',
      extra: {
        'before count': before.length,
        'after count': after.length,
        'inconsistent key count': idsDifference.length,
        'inconsistent key': '$idsDifference',
      },
      name: 'Sync Process',
    );

    return after;
  }
}
