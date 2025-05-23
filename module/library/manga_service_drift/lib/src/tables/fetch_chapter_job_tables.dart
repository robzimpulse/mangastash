import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('FetchChapterJobDrift')
class FetchChapterJobTables extends Table with AutoTimestampTable {
  TextColumn get mangaId => text().named('manga_id').nullable()();

  TextColumn get mangaTitle => text().named('manga_title').nullable()();

  TextColumn get coverUrl => text().named('cover_url').nullable()();

  TextColumn get chapterId => text().named('chapter_id').nullable()();

  IntColumn get chapterNumber => integer().named('chapter_number').nullable()();

  TextColumn get source => text().named('source').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {
        mangaId,
        mangaTitle,
        coverUrl,
        chapterId,
        chapterNumber,
        source,
      };
}
