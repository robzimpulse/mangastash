import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/manga_chapter.dart';

import '../use_case/history/listen_read_history_use_case.dart';
import '../use_case/history/listen_unread_history_use_case.dart';

class HistoryManager
    implements ListenReadHistoryUseCase, ListenUnreadHistoryUseCase {
  final HistoryDao _historyDao;

  HistoryManager({required HistoryDao historyDao}) : _historyDao = historyDao;

  StreamTransformer<List<HistoryModel>, List<MangaChapter>> get _transformer {
    return StreamTransformer.fromHandlers(
      handleData: (a, b) => b.add([...a.map(MangaChapter.fromDrift)]),
    );
  }

  @override
  Stream<List<MangaChapter>> get readHistoryStream {
    return _historyDao.history.transform(_transformer);
  }

  @override
  Stream<List<MangaChapter>> get unreadHistoryStream {
    return _historyDao.unread.transform(_transformer);
  }
}
