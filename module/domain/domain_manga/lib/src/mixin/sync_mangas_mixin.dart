import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required SyncMangasDao syncMangasDao,
    required List<Manga> values,
    required LogBox logBox,
  }) async {
    final tags = {...values.expand((e) => e.tags ?? <MangaTag>[])};

    var toUpdateTags = <MangaTag>{};
    var toInsertTags = <MangaTag>{};

    final tagResults = await syncMangasDao.searchTags(
      ids: tags.map((e) => e.id).nonNulls.nonEmpty.toList(),
      names: tags.map((e) => e.name).nonNulls.nonEmpty.toList(),
    );
    for (final tag in tags) {
      final match = tagResults.firstWhereOrNull((e) => e.name == tag.name);
      if (match != null) {
        toUpdateTags.add(tag.copyWith(id: match.id));
      } else {
        toInsertTags.add(tag);
      }
    }

    logBox.log(
      'Filtering Insert & Update Tags',
      extra: {
        'existing record found': tagResults.length,
        'inserted count': toInsertTags.length,
        'updated count': toUpdateTags.length,
        'total data': tags.length,
      },
      name: 'Sync Process',
    );

    // TODO: Insert Tags

    // TODO: Update Tags

    var toUpdateMangas = <Manga>{};
    var toInsertMangas = <Manga>{};
    final mangaResults = await syncMangasDao.searchMangas(
      ids: values.map((e) => e.id).nonNulls.nonEmpty.toList(),
      titles: values.map((e) => e.title).nonNulls.nonEmpty.toList(),
      webUrls: values.map((e) => e.webUrl).nonNulls.nonEmpty.toList(),
      sources: values.map((e) => e.source?.value).nonNulls.nonEmpty.toList(),
    );
    for (final manga in values) {
      final match = mangaResults.firstWhereOrNull(
        (e) => [
          e.title == manga.title,
          e.webUrl == manga.webUrl,
          e.source == manga.source?.value,
        ].every((isTrue) => isTrue),
      );
      if (match != null) {
        toUpdateMangas.add(manga.copyWith(id: match.id));
      } else {
        toInsertMangas.add(manga);
      }
    }

    logBox.log(
      'Filtering Insert & Update Manga',
      extra: {
        'existing record found': mangaResults.length,
        'inserted count': toInsertMangas.length,
        'updated count': toUpdateMangas.length,
        'total data': values.length,
      },
      name: 'Sync Process',
    );

    // TODO: Insert Manga

    // TODO: Update Manga

    return values;
  }
}
