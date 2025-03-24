import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

mixin SyncChaptersMixin {
  Future<List<MangaChapter>> sync({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required List<MangaChapter> values,
  }) {
    return Future.wait(
      values.map(
        (e) => mangaChapterServiceFirebase
            .sync(value: e.toFirebaseService())
            .then((e) => MangaChapter.fromFirebaseService(e)),
      ),
    );
  }
}
