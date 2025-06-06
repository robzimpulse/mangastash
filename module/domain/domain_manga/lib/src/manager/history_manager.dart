import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/history.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/listen_read_history_use_case.dart';

class HistoryManager implements ListenReadHistoryUseCase {
  final _stateSubject = BehaviorSubject<List<History>>.seeded([]);

  HistoryManager({required HistoryDao historyDao}) {
    _stateSubject.addStream(
      historyDao.history.map((e) => [...e.map((e) => History.fromDrift(e))]),
    );
  }

  @override
  Stream<List<History>> get readHistoryStream => _stateSubject.stream;
}
