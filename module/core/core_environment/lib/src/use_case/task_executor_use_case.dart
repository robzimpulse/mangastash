import 'package:worker_manager/worker_manager.dart';

abstract class TaskExecutor {
  Cancelable<R> execute<R>(
    Execute<R> execution, {
    WorkPriority priority = WorkPriority.immediately,
  });
}
