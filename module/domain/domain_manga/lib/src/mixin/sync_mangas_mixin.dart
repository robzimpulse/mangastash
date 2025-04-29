import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required List<Manga> mangas,
  }) async {
    final tags = await Future.wait(
      mangas
          .expand((e) => [...?e.tags])
          .toSet()
          .map(
            (e) => mangaTagServiceFirebase
                .sync(value: e.toFirebaseService())
                .then((value) => MangaTag.fromFirebaseService(value)),
          )
          .toList(),
    );

    final data = await Future.wait(
      mangas.map(
        (e) => mangaServiceFirebase.sync(
          value: e
              .copyWith(
                tags:
                    tags.where((tag) => e.tagsName.contains(tag.name)).toList(),
              )
              .toFirebaseService(),
        ),
      ),
    );

    return data.map((e) => Manga.fromFirebaseService(e)).toList();
  }
}
