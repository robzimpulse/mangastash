import 'package:drift/drift.dart';

class MangaTagRelationshipTables extends Table {

  TextColumn get tagId => text().named('tag_id')();

  TextColumn get mangaId => text().named('manga_id')();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();

  @override
  Set<Column<Object>>? get primaryKey => {tagId, mangaId};
}