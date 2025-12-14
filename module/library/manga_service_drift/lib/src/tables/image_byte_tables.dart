import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('ImageByteDrift')
class ImageByteTables extends Table with AutoTimestampTable, AutoTextIdTable {
  TextColumn get webUrl => text().named('web_url')();

  BlobColumn get byte => blob().named('byte').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {webUrl},
  ];
}
