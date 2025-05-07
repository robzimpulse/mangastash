import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../model/manga_drift.dart';
import '../model/manga_tag_drift.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';

part 'manga_dao.g.dart';

@DriftAccessor(tables: [MangaTables])
class MangaDao extends DatabaseAccessor<AppDatabase> with _$MangaDaoMixin {
  final Uuid _uuid;

  MangaDao({required AppDatabase db, Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(db);

  Future<List<MangaTable>> search({
    List<MangaTablesCompanion> mangas = const [],
  }) async {
    if (mangas.isEmpty) return [];

    final selector = select(mangaTables)
      ..where(
        (f) => [
          for (final manga in mangas)
            [
              if (manga.title.value?.isNotEmpty == true)
                f.title.like('%${manga.title}%'),
              if (manga.coverUrl.value?.isNotEmpty == true)
                f.title.like('%${manga.coverUrl}%'),
              if (manga.author.value?.isNotEmpty == true)
                f.title.like('%${manga.author}%'),
              if (manga.status.value?.isNotEmpty == true)
                f.title.like('%${manga.status}%'),
              if (manga.description.value?.isNotEmpty == true)
                f.title.like('%${manga.description}%'),
              if (manga.webUrl.value?.isNotEmpty == true)
                f.title.like('%${manga.webUrl}%'),
              if (manga.source.value?.isNotEmpty == true)
                f.title.like('%${manga.source}%'),
            ].reduce((result, element) => result & element),
        ].reduce((result, element) => result | element),
      )
      ..orderBy(
        [
          (f) => OrderingTerm(expression: f.updatedAt, mode: OrderingMode.desc),
          (f) => OrderingTerm(expression: f.title, mode: OrderingMode.asc),
        ],
      );

    return selector.get();
  }

  // Future<List<MangaTagDrift>> _searchTags({
  //   List<String> names = const [],
  // }) async {
  //   final selector = select(db.mangaTagTables)
  //     ..where(
  //       (e) => [
  //         ...names.map((name) => e.name.equals(name)),
  //       ].reduce((result, element) => result | element),
  //     );
  //
  //   final data = await selector.get();
  //
  //   return data.map((e) => MangaTagDrift.fromDb(tag: e)).toList();
  // }
  //
  // Future<List<MangaTagRelationshipTable>> _searchTagRelationship({
  //   List<String> tagIds = const [],
  //   List<String> mangaIds = const [],
  // }) {
  //   final selector = select(db.mangaTagRelationshipTables)
  //     ..where(
  //       (f) => [
  //         ...tagIds.map((e) => f.tagId.equals(e)),
  //         ...mangaIds.map((e) => f.mangaId.equals(e)),
  //       ].reduce((result, element) => result | element),
  //     );
  //
  //   return selector.get();
  // }
  //
  // Future<List<MangaTagDrift>> _syncTags(List<MangaTagDrift> tags) async {
  //   /// search for existing tags
  //   final found = await _searchTags(
  //     names: tags.map((e) => e.name).nonNulls.toList(),
  //   );
  //
  //   /// list of existing tags name
  //   final names = found.map((e) => e.name).nonNulls;
  //
  //   /// separate tags that need to be inserted
  //   final toInsert = tags.where((tag) => !names.contains(tag.name)).toList();
  //
  //   /// return all found tags if [toInsert] is empty
  //   if (toInsert.isEmpty) return found;
  //
  //   /// perform insert tags that not exist in database
  //   final inserted = await _insertTags(toInsert);
  //
  //   /// append inserted tags and found tags
  //   return [...found, ...inserted];
  // }
  //
  // Future<List<MangaTagDrift>> _insertTags(List<MangaTagDrift> tags) async {
  //   return transaction(() async {
  //     /// initialize variable
  //     var items = [...tags.map((e) => e.toDb())];
  //     List<MangaTagTable> success = [];
  //
  //     /// loop inserting until all items are inserted
  //     while (items.isNotEmpty) {
  //       /// get first item and remove from array [items]
  //       final item = items.removeAt(0);
  //
  //       /// try to add item to database
  //       try {
  //         /// if insert item were success, add to array [success]
  //         success.add(await into(mangaTagTables).insertReturning(item));
  //       } catch (e) {
  //         /// if failed to insert item, put it back to array [items] with
  //         /// modified id
  //         items.add(item.copyWith(id: _uuid.v4()));
  //       }
  //     }
  //
  //     /// return inserted tags
  //     return success.map((e) => MangaTagDrift.fromDb(tag: e)).toList();
  //   });
  // }
  //
  // Future<List<MangaDrift>> _insertMangas(List<MangaDrift> mangas) async {
  //   return transaction(() async {
  //     /// sync all tags for supplied [mangas]
  //     final tags = await _syncTags(
  //       [for (final manga in mangas) ...?manga.tags],
  //     );
  //
  //     /// select all manga-tag relationship
  //     final relationship = await _searchTagRelationship(
  //       mangaIds: [for (final manga in mangas) manga.id],
  //     );
  //
  //     /// initialize variable
  //     var items = [...mangas.map((e) => e.toDb())];
  //     List<MangaTable> success = [];
  //
  //     while (items.isNotEmpty) {
  //       /// get first item and remove from array [items]
  //       final item = items.removeAt(0);
  //
  //       /// try to add item to database
  //       try {
  //         /// if insert item were success, add to array [success]
  //         success.add(await into(mangaTables).insertReturning(item));
  //       } catch (e) {
  //         /// if failed to insert item, put it back to array [items] with
  //         /// modified id
  //         items.add(item.copyWith(id: _uuid.v4()));
  //       }
  //
  //       /// existing manga-tag relationship
  //       final tagsIds = relationship.where((e) => e.mangaId == item.id);
  //
  //       try {} catch (e) {}
  //     }
  //
  //     /// return inserted tags
  //     return success.map((e) => MangaDrift.fromDb(manga: e)).toList();
  //   });
  //   // return transaction(
  //   //   () async {
  //   //     // into(db.mangaTables).insertReturning(
  //   //     //   manga,
  //   //     //   onConflict: DoUpdate(
  //   //     //         (old) => MangaDrift(
  //   //     //       title: manga.title,
  //   //     //       coverUrl: manga.coverUrl,
  //   //     //       author: manga.author,
  //   //     //       status: manga.status,
  //   //     //       description: manga.description,
  //   //     //       webUrl: manga.webUrl,
  //   //     //       source: manga.source,
  //   //     //     ),
  //   //     //   ),
  //   //     // )
  //   //   },
  //   // );
  // }
  //
  //
  // //
  // // Future<void> batchInsert(List<MangaTable> mangas) {
  // //   /// TODO: insert tags
  // //   return transaction(
  // //     () => batch(
  // //       (batch) => batch.insertAllOnConflictUpdate(db.mangaTables, mangas),
  // //     ),
  // //   );
  // // }
  // //
  // // Future<List<MangaTable>> remove({required String id}) {
  // //   /// TODO: also remove attached tags if not used
  // //   return transaction(
  // //     () {
  // //       final selector = delete(db.mangaTables)..where((f) => f.id.equals(id));
  // //       return selector.goAndReturn();
  // //     },
  // //   );
  // // }
}
