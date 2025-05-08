import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

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
