import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('TagDrift')
class TagTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get tagId => text().named('tag_id').nullable()();

  TextColumn get name => text().named('name')();

  TextColumn get source => text().named('source').nullable()();

  // Per-source keys (schema v6): scraped sources derive tag ids from genre
  // slugs, so different sources share (tagId, name) pairs like
  // ('action', 'Action'). A global key made them collide.
  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {source, tagId},
    {source, name},
  ];
}
