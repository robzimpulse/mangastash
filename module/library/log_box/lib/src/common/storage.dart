import 'package:rxdart/rxdart.dart';

import '../model/entry.dart';
import '../model/log_entry.dart';
import '../model/network_entry.dart';
import '../model/webview_entry.dart';

class Storage {
  final BehaviorSubject<List<Entry>> _logs;

  final int _capacity;

  Storage({required int capacity})
    : _logs = BehaviorSubject.seeded([]),
      _capacity = capacity;

  Stream<List<Entry>> get all => _logs.stream;

  Stream<List<T>> typed<T>() =>
      _logs.stream.map((e) => [...e.whereType<T>()]).distinct();

  void add({required Entry log}) {
    var logs = [...?_logs.valueOrNull];
    final index = logs.indexWhere((e) => e.id == log.id);
    if (index >= 0) {
      final data = _merge(log: log, old: logs.removeAt(index));
      if (data != null) {
        _logs.add([...[data, ...logs].take(_capacity)]);
        return;
      }
    }

    _logs.add([...[log, ...logs].take(_capacity)]);
  }

  Entry? _merge({required Entry log, required Entry old}) {
    if (old is LogEntry && log is LogEntry) {
      return old.copyWith(
        message: log.message,
        extra: {...old.extra, ...log.extra},
      );
    }

    if (old is NetworkEntry && log is NetworkEntry) {
      return old.copyWith(
        loading: log.loading,
        request: log.request,
        response: log.response,
        error: log.error,
      );
    }

    if (old is WebviewEntry && log is WebviewEntry) {
      return old.copyWith(
        scripts: log.scripts,
        events: [...old.events, ...log.events],
      );
    }

    return null;
  }

  void clear() => _logs.add([]);
}
