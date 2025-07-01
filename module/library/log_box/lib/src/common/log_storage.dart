import 'package:rxdart/rxdart.dart';

import '../model/log_model.dart';

class LogStorage {
  final BehaviorSubject<List<LogModel>> _logs;

  final int _capacity;

  LogStorage({required int capacity})
      : _logs = BehaviorSubject.seeded([]),
        _capacity = capacity;

  Stream<List<LogModel>> get activities => _logs.stream;

  void addLog({required LogModel log}) {
    _logs.add([...[log, ...?_logs.valueOrNull].take(_capacity)]);
  }

  void clear() => _logs.add([]);
}
