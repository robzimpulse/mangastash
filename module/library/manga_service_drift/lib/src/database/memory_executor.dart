import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:file/file.dart';

import 'executor.dart';

class MemoryExecutor extends Executor {
  @override
  QueryExecutor build() {
    return DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    );
  }

  @override
  Future<File> databaseFile() {
    throw UnimplementedError('Memory database do not have any file');
  }

  @override
  Future<Directory> databaseDirectory() {
    throw UnimplementedError('Memory database do not have any directory');
  }
}
