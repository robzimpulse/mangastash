import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/manga_model.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'library_dao.g.dart';

@DriftAccessor(
  tables: [MangaTables, TagTables, RelationshipTables, LibraryTables],
)
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(super.db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    return select(libraryTables).join([
      innerJoin(mangaTables, mangaTables.id.equalsExp(libraryTables.mangaId)),
      leftOuterJoin(
        relationshipTables,
        relationshipTables.mangaId.equalsExp(libraryTables.mangaId),
      ),
      leftOuterJoin(
        tagTables,
        tagTables.id.equalsExp(relationshipTables.tagId),
      ),
    ])..orderBy([OrderingTerm.asc(mangaTables.title)]);
  }

  List<MangaModel> _parse(List<TypedResult> rows) {
    final groups = rows.groupListsBy((e) => e.readTableOrNull(mangaTables));
    return [
      for (final key in groups.keys.nonNulls)
        MangaModel(
          manga: key,
          tags: [
            ...?groups[key]?.map((e) => e.readTableOrNull(tagTables)).nonNulls,
          ],
        ),
    ];
  }

  Stream<List<MangaModel>> get stream => _aggregate.watch().map(_parse);

  Future<void> add(String mangaId) {
    final data = LibraryTablesCompanion.insert(mangaId: mangaId);
    return transaction(() => into(libraryTables).insert(data));
  }

  Future<void> remove(String mangaId) {
    final s = delete(libraryTables)..where((f) => f.mangaId.equals(mangaId));
    return transaction(() => s.go());
  }
}
