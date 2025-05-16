import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required SyncMangasDao syncMangasDao,
    required List<Manga> values,
  }) async {
    final mangas = <MangaFirebase>[];
    final tags = <MangaTagFirebase>{};

    for (final manga in values) {
      mangas.add(manga.toFirebaseService());
      for (final tag in manga.tags ?? <MangaTag>[]) {
        tags.add(tag.toFirebaseService());
      }
    }

    final existingTags = await mangaTagServiceFirebase.search(values: [...tags]);


    /// TODO: sync with firebase and local database
    return values;
  }
}
