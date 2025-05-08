import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required List<Manga> mangas,
  }) async {
    final tagNames = mangas.expand((e) => [...e.tagsName]).toSet();

    final tags = await Future.wait(
      tagNames.map(
        (e) => mangaTagServiceFirebase.sync(
          value: MangaTagFirebase(name: e),
        ),
      ),
    );

    final data = await Future.wait(
      mangas.map(
        (e) => mangaServiceFirebase.sync(
          value: e
              .copyWith(
                tags: tags
                    .where((tag) => e.tagsName.contains(tag.name))
                    .map((e) => MangaTag.fromFirebaseService(e))
                    .toList(),
              )
              .toFirebaseService(),
        ),
      ),
    );

    return data
        .map(
          (e) => Manga.fromFirebaseService(
            e,
            tags: tags
                .where((tag) => e.tagsId?.contains(tag.id) == true)
                .map((e) => MangaTag.fromFirebaseService(e))
                .toList(),
          ),
        )
        .toList();
  }
}
