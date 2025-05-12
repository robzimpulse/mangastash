import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

class MangaChapterImageTables extends Table with AutoTimestampTable {
  IntColumn get order => integer().named('order')();

  TextColumn get chapterId => text().named('chapter_id')();

  TextColumn get webUrl => text().named('webUrl')();

  TextColumn get id => text().named('id')();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}