import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('TagDrift')
class TagTables extends Table with AutoTimestampTable, AutoTextIdTable {

  TextColumn get name => text().named('name')();

  TextColumn get source => text().named('source').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {id, name, source},
      ];
}
