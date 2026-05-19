import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('DynamicSourceDrift')
class DynamicSourceTables extends Table with AutoTimestampTable, AutoTextIdTable {
  TextColumn get name => text().named('name')();

  TextColumn get baseUrl => text().named('base_url')();

  TextColumn get iconUrl => text().named('icon_url').nullable()();

  TextColumn get sourceCode => text().named('source_code')();

  BlobColumn get bytecode => blob().named('bytecode')();

  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {name},
    {baseUrl},
  ];
}
