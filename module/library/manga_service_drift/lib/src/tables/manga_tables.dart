import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('MangaDrift')
class MangaTables extends Table with AutoTimestampTable, AutoTextIdTable {
  TextColumn get title => text().named('title').nullable()();

  TextColumn get coverUrl => text().named('cover_url').nullable()();

  TextColumn get author => text().named('author').nullable()();

  TextColumn get status => text().named('status').nullable()();

  TextColumn get description => text().named('description').nullable()();

  TextColumn get webUrl => text().named('web_url').nullable()();

  TextColumn get source => text().named('source').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {webUrl, source}
      ];
}
