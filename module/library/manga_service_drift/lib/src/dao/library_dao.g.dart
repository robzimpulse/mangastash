// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_dao.dart';

// ignore_for_file: type=lint
mixin _$LibraryDaoMixin on DatabaseAccessor<AppDatabase> {
  $MangaTablesTable get mangaTables => attachedDatabase.mangaTables;
  $TagTablesTable get tagTables => attachedDatabase.tagTables;
  $RelationshipTablesTable get relationshipTables =>
      attachedDatabase.relationshipTables;
  $LibraryTablesTable get libraryTables => attachedDatabase.libraryTables;
  LibraryDaoManager get managers => LibraryDaoManager(this);
}

class LibraryDaoManager {
  final _$LibraryDaoMixin _db;
  LibraryDaoManager(this._db);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db.attachedDatabase, _db.mangaTables);
  $$TagTablesTableTableManager get tagTables =>
      $$TagTablesTableTableManager(_db.attachedDatabase, _db.tagTables);
  $$RelationshipTablesTableTableManager get relationshipTables =>
      $$RelationshipTablesTableTableManager(
        _db.attachedDatabase,
        _db.relationshipTables,
      );
  $$LibraryTablesTableTableManager get libraryTables =>
      $$LibraryTablesTableTableManager(_db.attachedDatabase, _db.libraryTables);
}
