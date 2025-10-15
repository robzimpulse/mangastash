import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/history.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/history/listen_read_history_use_case.dart';
import '../use_case/history/listen_unread_history_use_case.dart';

class HistoryManager
    implements ListenReadHistoryUseCase, ListenUnreadHistoryUseCase {
  final _historyStateSubject = BehaviorSubject<List<History>>.seeded([]);
  final _unreadStateSubject = BehaviorSubject<List<History>>.seeded([]);

  final List<StreamSubscription> subscriptions = [];

  HistoryManager({required HistoryDao historyDao}) {
    subscriptions.addAll([
      historyDao.history
          .map((e) => [...e.map((e) => History.fromDrift(e))])
          .listen(_historyStateSubject.add),
      historyDao.unread
          .map((e) => [...e.map((e) => History.fromDrift(e))])
          .listen(_unreadStateSubject.add),
    ]);
  }

  Future<void> dispose() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    subscriptions.clear();
  }

  @override
  Stream<List<History>> get readHistoryStream => _historyStateSubject.stream;

  @override
  Stream<List<History>> get unreadHistoryStream => _unreadStateSubject.stream;
}
