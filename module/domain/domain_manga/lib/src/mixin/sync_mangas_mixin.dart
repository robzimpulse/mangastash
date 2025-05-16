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
    final results = await syncMangasDao.searchTags(
      ids: tags.map((e) => e.id).nonNulls.nonEmpty.toList(),
      names: tags.map((e) => e.name).nonNulls.nonEmpty.toList(),
    );
    for (final tag in tags) {
      final match = results.firstWhereOrNull((e) => e.name == tag.name);
      if (match != null) {
        toUpdateTags.add(tag.copyWith(id: match.id, name: match.name));
      } else {
        toInsertTags.add(tag);
      }
    }

    logBox.log(
      'Tags',
      extra: {
        'existing record found': results.length,
        'inserted count': toInsertTags.length,
        'updated count': toUpdateTags.length,
        'total data': tags.length,
      },
      name: 'Sync Process',
    );

    /// TODO: sync with firebase and local database
    return values;
  }
}
