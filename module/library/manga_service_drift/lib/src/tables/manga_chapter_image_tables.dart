import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

class MangaChapterImageTables extends Table with AutoTimestampTable {
  Int64Column get id => int64().autoIncrement().named('id')();

  TextColumn get chapterId => text().named('chapter_id')();

  TextColumn get webUrl => text().named('webUrl')();
}