import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required List<MangaChapter> values,
  }) async {
    /// TODO: sync with firebase and local database
    return values;
  }
}
