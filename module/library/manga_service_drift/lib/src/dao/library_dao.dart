import 'package:drift/drift.dart';

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

  Stream<List<MangaDrift>> listenLibrary() {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
        ),
      ],
    );

    final stream = selector.watch();

    return stream.map(
      (rows) => [...rows.map((row) => row.readTable(mangaTables)).nonNulls],
    );
  }

  Future<void> add(String mangaId) async {
    await into(mangaLibraryTables).insert(
      MangaLibraryTablesCompanion.insert(mangaId: mangaId),
    );
  }

  Future<List<MangaDrift>> get() async {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
        ),
      ],
    );

    final results = await selector.get();

    return results.map((e) => e.readTable(mangaTables)).toList();
  }
}
