import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('TagDrift')
class TagTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get tagId => text().named('tag_id').nullable()();

  TextColumn get name => text().named('name')();

  TextColumn get source => text().named('source').nullable()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {tagId, name},
        {tagId, name, source},
      ];
}
