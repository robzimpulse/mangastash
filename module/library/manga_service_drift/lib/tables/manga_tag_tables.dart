import 'package:drift/drift.dart';

class MangaTagTables extends Table {

  TextColumn get id => text().named('id').nullable().call();

  TextColumn get name => text().named('name').nullable().call();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())
      .call();
}