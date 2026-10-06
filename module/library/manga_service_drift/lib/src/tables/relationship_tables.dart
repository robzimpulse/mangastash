import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

// Index on manga_id: the composite unique key {tag_id, manga_id} cannot
// serve the manga_id-only joins every manga aggregate query runs (issue
// #131) — manga_id is not its leftmost column.
@TableIndex(name: 'idx_relationship_manga_id', columns: {#mangaId})
class RelationshipTables extends Table with AutoTimestampTable {
  IntColumn get tagId => integer().named('tag_id')();

  TextColumn get mangaId => text().named('manga_id')();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {tagId, mangaId},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (tag_id) REFERENCES tag_tables (id) ON DELETE CASCADE',
    'FOREIGN KEY (manga_id) REFERENCES manga_tables (id) ON DELETE CASCADE',
  ];
}
