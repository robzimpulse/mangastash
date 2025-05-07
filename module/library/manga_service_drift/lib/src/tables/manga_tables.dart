import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

class MangaTables extends Table with AutoTimestampTable {
  TextColumn get id => text().named('id')();

  TextColumn get title => text().named('title').nullable()();

  TextColumn get coverUrl => text().named('cover_url').nullable()();

  TextColumn get author => text().named('author').nullable()();

  TextColumn get status => text().named('status').nullable()();

  TextColumn get description => text().named('description').nullable()();

  TextColumn get webUrl => text().named('webUrl').nullable()();

  TextColumn get source => text().named('source').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
