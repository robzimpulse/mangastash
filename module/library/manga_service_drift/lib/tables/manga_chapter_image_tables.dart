import 'package:drift/drift.dart';

class MangaChapterImageTables extends Table {
  Int64Column get id => int64().autoIncrement().named('id').call();

  TextColumn get chapterId => text().named('chapter_id').nullable().call();

  TextColumn get webUrl => text().named('webUrl').nullable().call();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())
      .call();
}