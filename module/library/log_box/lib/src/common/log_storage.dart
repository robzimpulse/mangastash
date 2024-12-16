import 'package:rxdart/rxdart.dart';
import 'package:uuid/v4.dart';

import '../model/log_model.dart';

class LogStorage {
  final BehaviorSubject<Map<String, LogModel>> _logs;

  LogStorage() : _logs = BehaviorSubject.seeded({});

  Stream<List<LogModel>> get activities {
    return _logs.stream.map((e) => e.values.toList());
  }

  void addLog({required LogModel log}) {
    _logs.add(
      Map.of(_logs.value)
        ..update(
          const UuidV4().generate(),
          (_) => log,
          ifAbsent: () => log,
        ),
    );
  }

  void clear() => _logs.add({});
}
