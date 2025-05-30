import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

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

  Stream<List<(MangaDrift, List<TagDrift>)>> get stream {
    final selector = select(libraryTables).join(
      [
        innerJoin(
          relationshipTables,
          relationshipTables.mangaId.equalsExp(
            libraryTables.mangaId,
          ),
        ),
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(relationshipTables.mangaId),
        ),
        innerJoin(
          tagTables,
          tagTables.id.equalsExp(relationshipTables.tagId),
        ),
      ],
    );

    final fallbackSelector = select(libraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(libraryTables.mangaId),
        ),
      ],
    );

    final stream = selector.watch();

    final data = SwitchLatestStream(
      stream.map(
        (e) => e.isNotEmpty ? Stream.value(e) : fallbackSelector.watch(),
      ),
    );

    return data.map(
      (rows) {
        final groups = rows
            .groupListsBy(
              (e) => e.readTableOrNull(mangaTables),
            )
            .map(
              (key, value) => MapEntry(
                key,
                value
                    .map((e) => e.readTableOrNull(tagTables))
                    .nonNulls
                    .toList(),
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
    await (delete(libraryTables)..where((f) => f.mangaId.equals(mangaId)))
        .go();
  }

  Future<List<(MangaDrift, List<TagDrift>)>> get() async {
    final selector = select(libraryTables).join(
      [
        innerJoin(
          relationshipTables,
          relationshipTables.mangaId.equalsExp(
            libraryTables.mangaId,
          ),
        ),
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(relationshipTables.mangaId),
        ),
        innerJoin(
          tagTables,
          tagTables.id.equalsExp(relationshipTables.tagId),
        ),
      ],
    );

    final fallbackSelector = select(libraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(libraryTables.mangaId),
        ),
      ],
    );

    final results = await selector.get();

    final groups = (results.isEmpty ? await fallbackSelector.get() : results)
        .groupListsBy((e) => e.readTableOrNull(mangaTables))
        .map(
          (key, value) => MapEntry(
            key,
            value
                .map((e) => e.readTableOrNull(tagTables))
                .nonNulls
                .toList(),
          ),
        );

    return [
      for (final key in groups.keys.nonNulls)
        (key, groups[key] ?? <TagDrift>[]),
    ];
  }
}
