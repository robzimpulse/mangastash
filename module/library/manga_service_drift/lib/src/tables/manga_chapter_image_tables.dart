import 'package:drift/drift.dart';

class MangaChapterImageTables extends Table {
  Int64Column get id => int64().autoIncrement().named('id')();

  TextColumn get chapterId => text().named('chapter_id').nullable()();

  TextColumn get webUrl => text().named('webUrl').nullable()();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}