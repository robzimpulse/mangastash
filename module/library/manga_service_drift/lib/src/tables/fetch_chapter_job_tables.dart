import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('FetchChapterJobDrift')
class FetchChapterJobTables extends Table  with AutoTimestampTable {
  TextColumn get mangaId => text().named('manga_id')();

  TextColumn get chapterId => text().named('chapter_id')();

  TextColumn get source => text().named('source')();

  @override
  Set<Column<Object>>? get primaryKey => {mangaId, chapterId, source};
}