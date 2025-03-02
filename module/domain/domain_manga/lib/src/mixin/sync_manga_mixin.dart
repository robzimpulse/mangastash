import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

mixin SyncMangaMixin {
  Future<Manga> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required Manga manga,
  }) async {
    return mangaServiceFirebase.sync(
      value: manga.copyWith(
        tags: await Future.wait(
          [
            ...manga.tagsName.map(
              (e) => mangaTagServiceFirebase.sync(value: MangaTag(name: e)),
            ),
          ],
        ),
      ),
    );
  }
}
