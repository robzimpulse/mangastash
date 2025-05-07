import 'package:drift/drift.dart';

import '../database/database.dart';
import '../tables/manga_tag_relationship_tables.dart';

part 'manga_tag_relationship_dao.g.dart';

@DriftAccessor(tables: [MangaTagRelationshipTables])
class MangaTagRelationshipDao extends DatabaseAccessor<AppDatabase>
    with _$MangaTagRelationshipDaoMixin {
  MangaTagRelationshipDao({required AppDatabase db}) : super(db);

  Future<List<MangaTagRelationshipTable>> search({
    List<String> tagIds = const [],
    List<String> mangaIds = const [],
  }) async {
    if (tagIds.isEmpty && mangaIds.isEmpty) return [];
    final selector = select(mangaTagRelationshipTables)
      ..where(
        (f) => [
          for (final e in tagIds)
            if (e.isNotEmpty) f.tagId.equals(e),
          for (final e in mangaIds)
            if (e.isNotEmpty) f.mangaId.equals(e),
        ].reduce((result, element) => result | element),
      );

    return selector.get();
  }

  Future<List<MangaTagRelationshipTable>> inserts(
    List<MangaTagRelationshipTable> relationships,
  ) async {
    return transaction(() async {
      /// initialize variable
      var items = [...relationships];
      List<MangaTagRelationshipTable> success = [];

      /// loop inserting until all items are inserted
      while (items.isNotEmpty) {
        /// get first item and remove from array [items]
        final item = items.removeAt(0);

        /// try to add item to database
        try {
          /// if insert item were success, add to array [success]
          success.add(
            await into(mangaTagRelationshipTables).insertReturning(item),
          );
        } catch (e) {
          /// if failed to insert item do nothing
        }
      }

      /// return inserted item
      return success;
    });
  }

  Future<List<MangaTagRelationshipTable>> remove({
    List<String> tagIds = const [],
    List<String> mangaIds = const [],
  }) async {
    if (tagIds.isEmpty && mangaIds.isEmpty) return [];
    return transaction(() async {
      final selector = delete(mangaTagRelationshipTables)
        ..where(
          (f) => [
            for (final e in tagIds)
              if (e.isNotEmpty) f.tagId.equals(e),
            for (final e in mangaIds)
              if (e.isNotEmpty) f.mangaId.equals(e),
          ].reduce((result, element) => result | element),
        );

      return selector.goAndReturn();
    });
  }
}
