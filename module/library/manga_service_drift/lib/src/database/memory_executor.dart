import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:universal_io/universal_io.dart';

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
  Future<File> getDatabaseFile() {
    throw UnimplementedError('Memory database do not have any path');
  }
}
