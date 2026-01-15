// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_dao.dart';

// ignore_for_file: type=lint
mixin _$JobDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobTablesTable get jobTables => attachedDatabase.jobTables;
  $MangaTablesTable get mangaTables => attachedDatabase.mangaTables;
  $ChapterTablesTable get chapterTables => attachedDatabase.chapterTables;
  $ImageTablesTable get imageTables => attachedDatabase.imageTables;
  JobDaoManager get managers => JobDaoManager(this);
}

class JobDaoManager {
  final _$JobDaoMixin _db;
  JobDaoManager(this._db);
  $$JobTablesTableTableManager get jobTables =>
      $$JobTablesTableTableManager(_db.attachedDatabase, _db.jobTables);
  $$MangaTablesTableTableManager get mangaTables =>
      $$MangaTablesTableTableManager(_db.attachedDatabase, _db.mangaTables);
  $$ChapterTablesTableTableManager get chapterTables =>
      $$ChapterTablesTableTableManager(_db.attachedDatabase, _db.chapterTables);
  $$ImageTablesTableTableManager get imageTables =>
      $$ImageTablesTableTableManager(_db.attachedDatabase, _db.imageTables);
}
