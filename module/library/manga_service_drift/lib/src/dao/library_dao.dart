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

  Stream<Iterable<MangaDrift>> listenLibrary() {
    final selector = select(mangaLibraryTables).join(
      [
        innerJoin(
          mangaTables,
          mangaTables.id.equalsExp(mangaLibraryTables.mangaId),
        ),
      ],
    );

    final stream = selector.watch();

    // TODO: populate manga tag
    return stream.map(
      (rows) => rows.map((row) => row.readTableOrNull(mangaTables)).nonNulls,
    );
  }
}
