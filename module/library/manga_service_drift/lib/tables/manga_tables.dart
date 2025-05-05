import 'package:drift/drift.dart';

import '../model/manga_drift.dart';

@UseRowClass(MangaDrift)
class MangaTables extends Table {
  TextColumn get id => text().named('id').nullable()();

  TextColumn get title => text().named('title').nullable()();

  TextColumn get coverUrl => text().named('cover_url').nullable()();

  TextColumn get author => text().named('author').nullable()();

  TextColumn get status => text().named('status').nullable()();

  TextColumn get description => text().named('description').nullable()();

  TextColumn get webUrl => text().named('webUrl').nullable()();

  TextColumn get source => text().named('source').nullable()();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();

  TextColumn get updatedAt => text()
      .named('updated_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}
