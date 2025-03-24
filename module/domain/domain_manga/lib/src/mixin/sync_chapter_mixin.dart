import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

mixin SyncChapterMixin {
  Future<MangaChapter> sync({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required MangaChapter value,
  }) {
    return mangaChapterServiceFirebase
        .sync(value: value.toFirebaseService())
        .then((e) => MangaChapter.fromFirebaseService(e));
  }
}
