// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_source_dao.dart';

// ignore_for_file: type=lint
mixin _$DynamicSourceDaoMixin on DatabaseAccessor<AppDatabase> {
  $DynamicSourceTablesTable get dynamicSourceTables =>
      attachedDatabase.dynamicSourceTables;
  DynamicSourceDaoManager get managers => DynamicSourceDaoManager(this);
}

class DynamicSourceDaoManager {
  final _$DynamicSourceDaoMixin _db;
  DynamicSourceDaoManager(this._db);
  $$DynamicSourceTablesTableTableManager get dynamicSourceTables =>
      $$DynamicSourceTablesTableTableManager(
        _db.attachedDatabase,
        _db.dynamicSourceTables,
      );
}
