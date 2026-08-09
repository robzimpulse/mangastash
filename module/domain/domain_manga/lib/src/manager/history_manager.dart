// HistoryManager streams history rows and filters them to those whose manga
// source is in the enabled-sources set (streamed by ListenSourcesUseCase), so
// disabled sources stay hidden app-wide. Constructor requires the use case;
// pass the concrete ListenSourcesUseCase (e.g. GlobalOptionsManager) in prod.
import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/manga_chapter.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/history/listen_read_history_use_case.dart';
import '../use_case/history/listen_unread_history_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';

class HistoryManager
    implements ListenReadHistoryUseCase, ListenUnreadHistoryUseCase {
  final HistoryDao _historyDao;
  final ListenSourcesUseCase _listenSourcesUseCase;

  HistoryManager({
    required HistoryDao historyDao,
    required ListenSourcesUseCase listenSourcesUseCase,
  }) : _historyDao = historyDao,
       _listenSourcesUseCase = listenSourcesUseCase;

  Stream<List<MangaChapter>> _filter(Stream<List<HistoryModel>> source) {
    return source.withLatestFrom(
      _listenSourcesUseCase.sourceStateStream,
      (histories, sources) {
        final enabled = {...sources.map((e) => e.name)};
        return [
          for (final model in histories)
            if (model.manga?.source case final source? when enabled.contains(source))
              MangaChapter.fromDrift(model),
        ];
      },
    );
  }

  @override
  Stream<List<MangaChapter>> get readHistoryStream {
    return _filter(_historyDao.history);
  }

  @override
  Stream<List<MangaChapter>> get unreadHistoryStream {
    return _filter(_historyDao.unread);
  }
}
