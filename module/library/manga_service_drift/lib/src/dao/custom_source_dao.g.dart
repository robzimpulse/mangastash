// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_source_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomSourceDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomSourceTablesTable get customSourceTables =>
      attachedDatabase.customSourceTables;
  CustomSourceDaoManager get managers => CustomSourceDaoManager(this);
}

class CustomSourceDaoManager {
  final _$CustomSourceDaoMixin _db;
  CustomSourceDaoManager(this._db);
  $$CustomSourceTablesTableTableManager get customSourceTables =>
      $$CustomSourceTablesTableTableManager(
        _db.attachedDatabase,
        _db.customSourceTables,
      );
}
