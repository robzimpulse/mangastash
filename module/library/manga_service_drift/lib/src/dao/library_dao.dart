import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
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

  JoinedSelectStatement<HasResultSet, dynamic> get aggregate {
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

  Stream<List<(MangaDrift, List<TagDrift>)>> get stream {
    final stream = aggregate.watch();

    return stream.map(
      (rows) {
        final groups = rows
            .groupListsBy(
              (e) => e.readTableOrNull(mangaTables),
            )
            .map(
              (key, value) => MapEntry(
                key,
                [...value.map((e) => e.readTableOrNull(tagTables)).nonNulls],
              ),
            );

        return [
          for (final key in groups.keys.nonNulls)
            (key, groups[key] ?? <TagDrift>[]),
        ];
      },
    );
  }

  Future<void> add(String mangaId) async {
    await into(libraryTables).insert(
      LibraryTablesCompanion.insert(mangaId: mangaId),
    );
  }

  Future<void> remove(String mangaId) async {
    await (delete(libraryTables)..where((f) => f.mangaId.equals(mangaId))).go();
  }

  Future<List<(MangaDrift, List<TagDrift>)>> get() async {
    final results = await aggregate.get();

    final groups = results.groupListsBy((e) => e.readTableOrNull(mangaTables));

    final data = groups.map(
      (key, value) => MapEntry(
        key,
        [...value.map((e) => e.readTableOrNull(tagTables)).nonNulls],
      ),
    );

    return [
      for (final key in data.keys.nonNulls) (key, data[key] ?? <TagDrift>[]),
    ];
  }
}
