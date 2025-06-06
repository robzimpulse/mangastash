import 'package:core_storage/core_storage.dart';
import 'package:rxdart/rxdart.dart';

class HistoryManager {
  final _stateSubject = BehaviorSubject<List<HistoryModel>>.seeded([]);

  HistoryManager({required HistoryDao libraryDao}) {
    _stateSubject.addStream(libraryDao.history);
  }

  // TODO: expose history entity

}