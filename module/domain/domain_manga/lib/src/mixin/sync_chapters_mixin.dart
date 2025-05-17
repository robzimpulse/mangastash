import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required ChapterDao chapterDao,
    required List<MangaChapter> values,
    required LogBox logBox,
  }) async {
    // TODO: sync with firebase and local database

    // final results = await chapterDao.searchChapters(
    //   mangaIds: {...values.map((e) => e.mangaId).nonNulls.nonEmpty}.toList(),
    // );
    //
    // var toUpdate = <(MangaChapterTablesCompanion, List<String>)>{};
    // var toInsert = <(MangaChapterTablesCompanion, List<String>)>{};
    //
    // for (final chapter in values) {
    //   final match = results.firstWhereOrNull(
    //     (e) => [
    //       e.title == chapter.mangaTitle,
    //       e.webUrl == chapter.mangaId,
    //     ].every((isTrue) => isTrue),
    //   );
    //   final data = chapter.copyWith(id: match?.id).toDrift;
    //   match != null ? toUpdate.add((data, chapter.images ?? [])) : toInsert.add((data, chapter.images ?? []));
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

    return values;
  }
}
