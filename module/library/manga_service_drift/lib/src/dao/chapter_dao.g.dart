// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_dao.dart';

// ignore_for_file: type=lint
mixin _$ChapterDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChapterTablesTable get chapterTables => attachedDatabase.chapterTables;
  $ImageTablesTable get imageTables => attachedDatabase.imageTables;
  ChapterDaoManager get managers => ChapterDaoManager(this);
}

class ChapterDaoManager {
  final _$ChapterDaoMixin _db;
  ChapterDaoManager(this._db);
  $$ChapterTablesTableTableManager get chapterTables =>
      $$ChapterTablesTableTableManager(_db.attachedDatabase, _db.chapterTables);
  $$ImageTablesTableTableManager get imageTables =>
      $$ImageTablesTableTableManager(_db.attachedDatabase, _db.imageTables);
}
