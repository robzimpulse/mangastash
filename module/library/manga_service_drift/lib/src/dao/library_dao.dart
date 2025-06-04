import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../model/library_model.dart';
import '../tables/library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/relationship_tables.dart';
import '../tables/tag_tables.dart';

part 'library_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    TagTables,
    RelationshipTables,
    LibraryTables,
  ],
)
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(AppDatabase db) : super(db);

  JoinedSelectStatement<HasResultSet, dynamic> get _aggregate {
    final order = [
      OrderingTerm(expression: mangaTables.title, mode: OrderingMode.asc),
    ];

    return select(libraryTables).join(
      [
        leftOuterJoin(
          mangaTables,
          mangaTables.id.equalsExp(libraryTables.mangaId),
        ),
        leftOuterJoin(
          relationshipTables,
          relationshipTables.mangaId.equalsExp(
            libraryTables.mangaId,
          ),
        ),
        leftOuterJoin(
          tagTables,
          tagTables.id.equalsExp(relationshipTables.tagId),
        ),
      ],
    )..orderBy(order);
  }

  List<LibraryModel> _parse(List<TypedResult> rows) {
    final groups = rows.groupListsBy((e) => e.readTableOrNull(mangaTables));
    return [
      for (final key in groups.keys.nonNulls)
        LibraryModel(
          manga: key,
          tags: [
            ...?groups[key]?.map((e) => e.readTableOrNull(tagTables)).nonNulls,
          ],
        ),
    ];
  }

  Stream<List<LibraryModel>> get stream {
    return _aggregate.watch().map((rows) => _parse(rows));
  }

  Future<void> add(String mangaId) {
    return transaction(
      () => into(libraryTables).insert(
        LibraryTablesCompanion.insert(mangaId: mangaId),
      ),
    );
  }

  Future<void> remove(String mangaId) {
    final s = delete(libraryTables)..where((f) => f.mangaId.equals(mangaId));
    return transaction(() => s.go());
  }

  Future<List<LibraryModel>> get() {
    return _aggregate.get().then((rows) => _parse(rows));
  }
}
