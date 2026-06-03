import 'package:drift/drift.dart';
import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('CustomSourceDrift')
class CustomSourceTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get name => text().named('name')();
  TextColumn get baseUrl => text().named('base_url')();
  TextColumn get iconUrl => text().named('icon_url').nullable()();
  TextColumn get scriptUrl => text().named('script_url').unique()();
  TextColumn get scriptCode => text().named('script_code')();

}
