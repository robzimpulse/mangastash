import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'executor.dart';

class MemoryExecutor extends Executor {

  final QueryExecutor? _executor;

  const MemoryExecutor({QueryExecutor? executor}): _executor = executor;

  @override
  QueryExecutor build() {
    return _executor ?? DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    );
  }
}
