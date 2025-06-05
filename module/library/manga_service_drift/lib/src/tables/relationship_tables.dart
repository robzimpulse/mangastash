import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

class RelationshipTables extends Table with AutoTimestampTable {
  TextColumn get tagId => text().named('tag_id')();

  TextColumn get mangaId => text().named('manga_id')();

  @override
  Set<Column<Object>>? get primaryKey => {tagId, mangaId};
}