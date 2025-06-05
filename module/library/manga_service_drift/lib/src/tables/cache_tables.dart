import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('CacheDrift')
class CacheTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get url => text().named('url')();

  TextColumn get key => text().named('key')();

  TextColumn get relativePath => text().named('relativePath')();

  TextColumn get eTag => text().named('e_tag').nullable()();

  DateTimeColumn get validTill => dateTime().named('valid_till')();

  DateTimeColumn get touched => dateTime().named('touched').nullable()();

  IntColumn get length => integer().named('length').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}