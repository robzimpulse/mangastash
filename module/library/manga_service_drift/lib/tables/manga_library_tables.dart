import 'package:drift/drift.dart';

import 'manga_tables.dart';

class MangaLibraryTables extends Table {
  Int64Column get id => int64().named('id').autoIncrement()();

  TextColumn get mangaId =>
      text().named('manga_id').references(MangaTables, #id)();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}
