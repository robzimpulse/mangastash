import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'executor.dart';

class MemoryExecutor extends Executor {
  @override
  QueryExecutor build() {
    return DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    );
  }
}
