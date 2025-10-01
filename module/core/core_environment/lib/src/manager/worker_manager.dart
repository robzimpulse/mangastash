import 'package:worker_manager/worker_manager.dart';

import '../use_case/task_executor_use_case.dart';

class WorkerManager implements TaskExecutor {
  static Future<WorkerManager> create() async {
    await workerManager.init(dynamicSpawning: true);
    return const WorkerManager._();
  }

  const WorkerManager._();

  @override
  Cancelable<R> execute<R>(
    Execute<R> execution, {
    WorkPriority priority = WorkPriority.immediately,
  }) {
    return workerManager.execute(execution, priority: priority);
  }

  Future<void> dispose() => workerManager.dispose();
}
