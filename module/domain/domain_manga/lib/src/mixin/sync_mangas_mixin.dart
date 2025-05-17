import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaDao mangaDao,
    required List<Manga> values,
    required LogBox logBox,
  }) async {
    final tags = {...values.expand((e) => e.tags ?? <MangaTag>[])};

    var toUpdateTags = <MangaTagTablesCompanion>{};
    var toInsertTags = <MangaTagTablesCompanion>{};

    final tagResults = await mangaDao.searchTags(
      ids: tags.map((e) => e.id).nonNulls.nonEmpty.toList(),
      names: tags.map((e) => e.name).nonNulls.nonEmpty.toList(),
    );
    for (final tag in tags) {
      final match = tagResults.firstWhereOrNull((e) => e.name == tag.name);
      final data = tag.toDrift.copyWith(id: Value.absentIfNull(match?.id));
      match != null ? toUpdateTags.add(data) : toInsertTags.add(data);
    }

    final updatedTags = [
      for (final tag in toUpdateTags) ...await mangaDao.updateTag(tag),
      for (final tag in toInsertTags) await mangaDao.insertTag(tag),
    ];

    logBox.log(
      'Insert & Update Tags',
      extra: {
        'existing record found': tagResults.length,
        'inserted count': toInsertTags.length,
        'updated count': toUpdateTags.length,
        'total data': tags.length,
        'total updated': updatedTags.length,
      },
      name: 'Sync Process',
    );

    var toUpdateMangas = <(MangaTablesCompanion, List<String>)>{};
    var toInsertMangas = <(MangaTablesCompanion, List<String>)>{};
    final mangaResults = await mangaDao.searchMangas(
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
      final data = manga.toDrift.copyWith(id: Value.absentIfNull(match?.id));
      match != null
          ? toUpdateMangas.add((data, manga.tagsName))
          : toInsertMangas.add((data, manga.tagsName));
    }

    final updatedMangas = <(MangaDrift, List<String>)>[];
    for (final (manga, tags) in toUpdateMangas) {
      final results = await mangaDao.updateManga(manga);
      final tagIds = tags.map(
        (e) => updatedTags.firstWhereOrNull((tag) => tag.name == e)?.id,
      );
      for (final result in results) {
        await mangaDao.unlinkAllTagFromManga(result.id);
        await mangaDao.linkTagToManga(result.id, tagIds.nonNulls.nonEmpty);
        updatedMangas.add((result, [...tagIds.nonNulls.nonEmpty]));
      }
    }
    for (final (manga, tags) in toInsertMangas) {
      final tagIds = tags.map(
        (e) => updatedTags.firstWhereOrNull((tag) => tag.name == e)?.id,
      );
      final result = await mangaDao.insertManga(manga);
      await mangaDao.linkTagToManga(result.id, tagIds.nonNulls.nonEmpty);
      updatedMangas.add((result, [...tagIds.nonNulls.nonEmpty]));
    }

    logBox.log(
      'Insert & Update Manga',
      extra: {
        'existing record found': mangaResults.length,
        'inserted count': toInsertMangas.length,
        'updated count': toUpdateMangas.length,
        'total data': values.length,
        'total updated': updatedMangas.length,
      },
      name: 'Sync Process',
    );

    return [
      for (final (value, tagIds) in updatedMangas)
        Manga.fromDrift(
          value,
          tags: updatedTags.where((e) => tagIds.contains(e)).toList(),
        ),
    ];
  }
}
