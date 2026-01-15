// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_dao.dart';

// ignore_for_file: type=lint
mixin _$FileDaoMixin on DatabaseAccessor<AppDatabase> {
  $FileTablesTable get fileTables => attachedDatabase.fileTables;
  FileDaoManager get managers => FileDaoManager(this);
}

class FileDaoManager {
  final _$FileDaoMixin _db;
  FileDaoManager(this._db);
  $$FileTablesTableTableManager get fileTables =>
      $$FileTablesTableTableManager(_db.attachedDatabase, _db.fileTables);
}
