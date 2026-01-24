// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_dao.dart';

// ignore_for_file: type=lint
mixin _$ImageDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImageTablesTable get imageTables => attachedDatabase.imageTables;
  ImageDaoManager get managers => ImageDaoManager(this);
}

class ImageDaoManager {
  final _$ImageDaoMixin _db;
  ImageDaoManager(this._db);
  $$ImageTablesTableTableManager get imageTables =>
      $$ImageTablesTableTableManager(_db.attachedDatabase, _db.imageTables);
}
