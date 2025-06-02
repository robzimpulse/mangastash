import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('ImageDrift')
class ImageTables extends Table with AutoTimestampTable {
  IntColumn get order => integer().named('order')();

  TextColumn get chapterId => text().named('chapter_id')();

  TextColumn get webUrl => text().named('web_url')();

  TextColumn get id => text().named('id')();

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
