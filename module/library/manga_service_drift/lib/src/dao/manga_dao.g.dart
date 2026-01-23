// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_dao.dart';

// ignore_for_file: type=lint
mixin _$MangaDaoMixin on DatabaseAccessor<AppDatabase> {
  $MangaTablesTable get mangaTables => attachedDatabase.mangaTables;
  $TagTablesTable get tagTables => attachedDatabase.tagTables;
  $RelationshipTablesTable get relationshipTables =>
      attachedDatabase.relationshipTables;
  MangaDaoManager get managers => MangaDaoManager(this);
}

class MangaDaoManager {
  final _$MangaDaoMixin _db;
  MangaDaoManager(this._db);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db.attachedDatabase, _db.mangaTables);
  $$TagTablesTableTableManager get tagTables =>
      $$TagTablesTableTableManager(_db.attachedDatabase, _db.tagTables);
  $$RelationshipTablesTableTableManager get relationshipTables =>
      $$RelationshipTablesTableTableManager(
        _db.attachedDatabase,
        _db.relationshipTables,
      );
}
