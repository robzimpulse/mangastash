import 'dart:async';

extension SafeCompleter<T> on Completer<T> {
  void safeComplete([FutureOr<T>? value]) {
    if (isCompleted) return;
    complete(value);
  }

  void safeCompleteError(Object error, [StackTrace? stackTrace]) {
    if (isCompleted) return;
    completeError(error, stackTrace);
  }
}