import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/history.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/history/listen_read_history_use_case.dart';
import '../use_case/history/listen_unread_history_use_case.dart';

class HistoryManager
    implements ListenReadHistoryUseCase, ListenUnreadHistoryUseCase {
  final _historyStateSubject = BehaviorSubject<List<History>>.seeded([]);
  final _unreadStateSubject = BehaviorSubject<List<History>>.seeded([]);

  HistoryManager({required HistoryDao historyDao}) {
    _historyStateSubject.addStream(
      historyDao.history.map((e) => [...e.map((e) => History.fromDrift(e))]),
    );
    _unreadStateSubject.addStream(
      historyDao.unread.map((e) => [...e.map((e) => History.fromDrift(e))]),
    );
  }

  @override
  Stream<List<History>> get readHistoryStream => _historyStateSubject.stream;

  @override
  Stream<List<History>> get unreadHistoryStream => _unreadStateSubject.stream;
}
