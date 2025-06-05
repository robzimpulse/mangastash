import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';

@DataClassName('ChapterDrift')
class ChapterTables extends Table with AutoTimestampTable, AutoTextIdTable {
  TextColumn get mangaId => text().named('manga_id').nullable()();

  TextColumn get title => text().named('title').nullable()();

  TextColumn get volume => text().named('volume').nullable()();

  TextColumn get chapter => text().named('chapter').nullable()();

  TextColumn get translatedLanguage =>
      text().named('translated_language').nullable()();

  TextColumn get scanlationGroup =>
      text().named('scanlation_group').nullable()();

  TextColumn get webUrl => text().named('webUrl').nullable()();

  DateTimeColumn get readableAt => dateTime().named('readable_at').nullable()();

  DateTimeColumn get publishAt => dateTime().named('publish_at').nullable()();

  DateTimeColumn get lastReadAt =>
      dateTime().named('last_read_at').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {mangaId, webUrl, title},
        {mangaId, title},
        {mangaId, webUrl},
        {webUrl, title},
      ];
}
