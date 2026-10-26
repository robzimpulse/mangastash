// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_script_dao.dart';

// ignore_for_file: type=lint
mixin _$SourceScriptDaoMixin on DatabaseAccessor<AppDatabase> {
  $SourceScriptTablesTable get sourceScriptTables =>
      attachedDatabase.sourceScriptTables;
  SourceScriptDaoManager get managers => SourceScriptDaoManager(this);
}

class SourceScriptDaoManager {
  final _$SourceScriptDaoMixin _db;
  SourceScriptDaoManager(this._db);
  $$SourceScriptTablesTableTableManager get sourceScriptTables =>
      $$SourceScriptTablesTableTableManager(
        _db.attachedDatabase,
        _db.sourceScriptTables,
      );
}
