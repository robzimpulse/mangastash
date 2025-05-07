import 'package:drift/drift.dart';

class MangaTagTables extends Table {

  TextColumn get id => text().named('id')();

  TextColumn get name => text().named('name')();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}