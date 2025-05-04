import 'package:drift/drift.dart';

import 'tables/manga_chapter_image_tables.dart';
import 'tables/manga_chapter_tables.dart';
import 'tables/manga_tables.dart';
import 'tables/manga_tag_tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    MangaTables,
    MangaChapterTables,
    MangaChapterImageTables,
    MangaTagTables,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
