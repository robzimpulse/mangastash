import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('TagDrift')
class TagTables extends Table with AutoTimestampTable {
  TextColumn get id => text().named('id')();

  TextColumn get name => text().named('name')();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {id, name},
      ];
}
