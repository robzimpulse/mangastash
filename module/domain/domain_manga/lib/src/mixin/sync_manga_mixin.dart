import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

mixin SyncMangaMixin {
  Future<Manga> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required Manga manga,
  }) async {
    final tags = manga.tags?.map(
      (e) => mangaTagServiceFirebase
          .sync(value: e.toFirebaseService())
          .then((e) => MangaTag.fromFirebaseService(e)),
    );

    final data = await mangaServiceFirebase.sync(
      value: manga
          .copyWith(tags: await Future.wait(tags ?? []))
          .toFirebaseService(),
    );

    return Manga.fromFirebaseService(data);
  }
}
