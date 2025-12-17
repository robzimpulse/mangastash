import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('FileDrift')
class FileTables extends Table with AutoTimestampTable, AutoTextIdTable {
  TextColumn get webUrl => text().named('web_url')();

  TextColumn get relativePath => text().named('relative_path').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {webUrl},
  ];
}
