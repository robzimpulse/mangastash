import 'package:drift/drift.dart';

class MangaTagTables extends Table {

  TextColumn get id => text().named('id').nullable()();

  TextColumn get name => text().named('name').nullable()();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}