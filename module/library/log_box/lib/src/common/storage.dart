import 'package:rxdart/rxdart.dart';

import '../model/entry.dart';

class Storage {
  final BehaviorSubject<List<Entry>> _logs;

  final int _capacity;

  Storage({required int capacity})
    : _logs = BehaviorSubject.seeded([]),
      _capacity = capacity;

  Stream<List<Entry>> get all => _logs.stream;

  Stream<List<T>> typed<T>() => _logs.stream.map((e) => [...e.whereType<T>()]);

  void add({required Entry log}) {
    _logs.add([
      ...[log, ...?_logs.valueOrNull].take(_capacity),
    ]);
  }

  void clear() => _logs.add([]);
}
