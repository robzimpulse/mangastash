/// Drift table holding user-editable JavaScript source scripts (issue #115).
///
/// One row per script: `id` is the script id (e.g. `asura-scans`), `name` is
/// the unique display name, `code` the JavaScript body, `version` the row's
/// own version, `origin` where it came from and `baseVersion` the shipped
/// version a `shippedEdited` row was forked from (null for custom scripts).
///
/// Usage: do not touch directly; go through `SourceScriptDao`. Added in
/// schema v7. Run `melos exec --scope=manga_service_drift --
/// "fvm flutter pub run build_runner build --delete-conflicting-outputs"`
/// after changing it.
library;

import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';
import '../util/source_script_origin.dart';

@DataClassName('SourceScriptDrift')
class SourceScriptTables extends Table with AutoTimestampTable {
  TextColumn get id => text().named('id')();

  TextColumn get name => text().named('name').unique()();

  TextColumn get code => text().named('code')();

  IntColumn get version => integer().named('version')();

  TextColumn get origin => textEnum<SourceScriptOrigin>().named('origin')();

  IntColumn get baseVersion => integer().named('base_version').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
