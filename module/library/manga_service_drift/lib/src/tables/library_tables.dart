import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('LibraryDrift')
class LibraryTables extends Table with AutoTimestampTable {
  TextColumn get mangaId => text().named('manga_id')();

  @override
  Set<Column<Object>>? get primaryKey => {mangaId};

}
