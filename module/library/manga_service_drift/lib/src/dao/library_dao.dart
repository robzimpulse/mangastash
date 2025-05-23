import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../database/database.dart';
import '../tables/manga_library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';

part 'library_dao.g.dart';

@DriftAccessor(
  tables: [
    MangaTables,
    MangaTagTables,
    MangaTagRelationshipTables,
    MangaLibraryTables,
  ],
)
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(AppDatabase db) : super(db);

  Stream<List<(MangaDrift, List<TagDrift>)>> get stream {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTagRelationshipTables,
          mangaTagRelationshipTables.mangaId.equalsExp(
            mangaLibraryTables.mangaId,
          ),
        ),
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaTagRelationshipTables.mangaId),
        ),
        innerJoin(
          mangaTagTables,
          mangaTagTables.id.equalsExp(mangaTagRelationshipTables.tagId),
        ),
      ],
    );

    final fallbackSelector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
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
                    .map((e) => e.readTableOrNull(mangaTagTables))
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
    await into(mangaLibraryTables).insert(
      MangaLibraryTablesCompanion.insert(mangaId: mangaId),
    );
  }

  Future<void> remove(String mangaId) async {
    await (delete(mangaLibraryTables)..where((f) => f.mangaId.equals(mangaId)))
        .go();
  }

  Future<List<(MangaDrift, List<TagDrift>)>> get() async {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTagRelationshipTables,
          mangaTagRelationshipTables.mangaId.equalsExp(
            mangaLibraryTables.mangaId,
          ),
        ),
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaTagRelationshipTables.mangaId),
        ),
        innerJoin(
          mangaTagTables,
          mangaTagTables.id.equalsExp(mangaTagRelationshipTables.tagId),
        ),
      ],
    );

    final fallbackSelector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
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
                .map((e) => e.readTableOrNull(mangaTagTables))
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
