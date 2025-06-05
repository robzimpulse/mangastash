import 'dart:async';

import 'package:drift/drift.dart';

import '../util/typedef.dart';

class LogInterceptor extends QueryInterceptor {
  final LoggerCallback? _logger;

  LogInterceptor({LoggerCallback? logger}) : _logger = logger;

  Future<T> _run<T>({
    required String description,
    String? statement,
    List<Object?>? args,
    required FutureOr<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      _logger?.call(
        '$description success [$statement]',
        extra: {
          'statement': statement,
          'args': args,
          'result': result,
          'duration': stopwatch.elapsedMilliseconds,
        },
        name: runtimeType.toString(),
      );
      return result;
    } on Object catch (e) {
      _logger?.call(
        '$description failed [$statement]',
        extra: {
          'statement': statement,
          'args': args,
          'result': e,
          'duration': stopwatch.elapsedMilliseconds,
        },
        name: runtimeType.toString(),
      );
      rethrow;
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    _logger?.call('Begin', name: runtimeType.toString());
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _run(description: 'Commit', operation: () => inner.send());
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _run(description: 'Rollback', operation: () => inner.rollback());
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    return _run(
      description: 'Batch',
      statement: statements.toString(),
      operation: () => executor.runBatched(statements),
    );
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Insert',
      statement: statement,
      args: args,
      operation: () => executor.runInsert(statement, args),
    );
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Update',
      statement: statement,
      args: args,
      operation: () => executor.runUpdate(statement, args),
    );
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Delete',
      statement: statement,
      args: args,
      operation: () => executor.runDelete(statement, args),
    );
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Custom',
      statement: statement,
      args: args,
      operation: () => executor.runCustom(statement, args),
    );
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Select',
      statement: statement,
      args: args,
      operation: () => executor.runSelect(statement, args),
    );
  }
}
