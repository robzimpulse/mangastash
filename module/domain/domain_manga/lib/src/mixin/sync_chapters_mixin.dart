import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required ChapterDao chapterDao,
    required List<MangaChapter> values,
    required LogBox logBox,
  }) async {

    return values;
    // final results = await chapterDao.searchChapters(
    //   ids: values.map((e) => e.id).nonNulls.toList(),
    //   mangaIds: values.map((e) => e.mangaId).nonNulls.toList(),
    //   mangaTitles: values.map((e) => e.mangaTitle).nonNulls.toList(),
    //   titles: values.map((e) => e.title).nonNulls.toList(),
    //   volumes: values.map((e) => e.volume).nonNulls.toList(),
    //   chapters: values.map((e) => e.chapter).nonNulls.toList(),
    //   translatedLanguages:
    //       values.map((e) => e.translatedLanguage).nonNulls.toList(),
    //   scanlationGroups: values.map((e) => e.scanlationGroup).nonNulls.toList(),
    //   webUrls: values.map((e) => e.webUrl).nonNulls.toList(),
    // );
    //
    // var toUpdate = <(MangaChapterTablesCompanion, List<String>)>{};
    // var toInsert = <(MangaChapterTablesCompanion, List<String>)>{};
    //
    // for (final chapter in values) {
    //   final match = results.firstWhereOrNull(
    //     (e) => [
    //       e.mangaTitle == chapter.mangaTitle,
    //       e.mangaId == chapter.mangaId,
    //       e.webUrl == chapter.webUrl,
    //     ].every((isTrue) => isTrue),
    //   );
    //   final data = chapter.copyWith(id: chapter.id ?? match?.id).toDrift;
    //   match != null
    //       ? toUpdate.add((data, chapter.images ?? []))
    //       : toInsert.add((data, chapter.images ?? []));
    // }
    //
    // final updated = <(ChapterDrift, List<ImageDrift>)>[];
    // for (final (chapter, images) in toUpdate) {
    //   final updates = await chapterDao.updateChapter(chapter);
    //   for (final update in updates) {
    //     final data = await chapterDao.setImages(update.id, images);
    //     updated.add((update, data));
    //   }
    // }
    // for (final (chapter, images) in toInsert) {
    //   final update = await chapterDao.insertChapter(chapter);
    //   final data = await chapterDao.setImages(update.id, images);
    //   updated.add((update, data));
    // }
    //
    // logBox.log(
    //   'Insert & Update Chapter',
    //   extra: {
    //     'existing record found': results.length,
    //     'inserted count': toInsert.length,
    //     'updated count': toUpdate.length,
    //     'total data': values.length,
    //     'total updated': updated.length,
    //   },
    //   name: 'Sync Process',
    // );
    //
    // {
    //   final anomaly = <String, String>{};
    //   final before = {for (final e in values) e.webUrl: e.id};
    //   final after = {for (final (e, _) in updated) e.webUrl: e.id};
    //   for (final key in {...before.keys, ...after.keys}.nonNulls) {
    //     if (before[key] == null) continue;
    //     if (before[key] == after[key]) continue;
    //     anomaly[key] = '${before[key]} -> ${after[key]}';
    //   }
    //   if (anomaly.isNotEmpty) {
    //     logBox.log(
    //       'Anomaly Chapter',
    //       extra: {
    //         'changed record': anomaly.length,
    //         ...anomaly,
    //       },
    //       name: 'Sync Process',
    //     );
    //   }
    // }
    //
    // return [
    //   for (final (chapter, images) in updated)
    //     MangaChapter.fromDrift(chapter, images: images),
    // ];
  }
}
