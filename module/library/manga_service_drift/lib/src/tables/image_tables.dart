import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('ImageDrift')
class ImageTables extends Table with AutoTimestampTable, AutoTextIdTable {
  IntColumn get order => integer().named('order')();

  TextColumn get chapterId => text().named('chapter_id')();

  TextColumn get webUrl => text().named('web_url')();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {chapterId, webUrl, order},
        {chapterId, webUrl},
        {webUrl, order},
        {chapterId, order},
      ];
}
