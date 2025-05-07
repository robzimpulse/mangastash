import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

class MangaLibraryTables extends Table with AutoTimestampTable {
  Int64Column get id => int64().named('id').autoIncrement()();

  TextColumn get mangaId => text().named('manga_id')();
}
