import 'package:flutter/foundation.dart';

class MeasureProcessUseCase<T> {

  final _stopwatch = Stopwatch();

  Duration get elapsed => _stopwatch.elapsed;

  MeasureProcessUseCase();

  Future<T> execute(AsyncValueGetter<T> process) {
    _stopwatch.start();
    final value = process.call();
    _stopwatch.stop();
    return value;
  }

}