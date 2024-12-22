import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/listen_active_download_use_case.dart';

class ActiveDownloadManager implements ListenActiveDownloadUseCase {
  final BehaviorSubject<Set<DownloadChapterKey>> _active;
  final FileDownloader _fileDownloader;
  final LogBox _log;
  StreamSubscription? _streamSubscription;

  static Future<ActiveDownloadManager> create({
    required FileDownloader fileDownloader,
    required LogBox log,
  }) async {
    final records = await fileDownloader.database.allRecords();
    return ActiveDownloadManager(
      fileDownloader: fileDownloader,
      log: log,
      activeDownloadKey: Set.of(
        records
            .where((record) => record.status.isNotFinalState)
            .groupListsBy(
              (record) => DownloadChapterKey.fromJsonString(record.group),
            )
            .keys,
      ),
    );
  }

  ActiveDownloadManager({
    required Set<DownloadChapterKey> activeDownloadKey,
    required FileDownloader fileDownloader,
    required LogBox log,
  })  : _active = BehaviorSubject.seeded(activeDownloadKey),
        _log = log,
        _fileDownloader = fileDownloader {
    _streamSubscription = fileDownloader.updates.distinct().listen(_onUpdate);
  }

  void dispose() {
    _streamSubscription?.cancel();
  }

  void _onUpdate(TaskUpdate event) async {
    final task = event.task;
    if (event is TaskStatusUpdate && event.status.isFinalState) {
      final records = await _fileDownloader.database.allRecords(
        group: task.group,
      );
      if (records.every((record) => record.status.isFinalState)) {
        final key = DownloadChapterKey.fromJsonString(event.task.group);
        _active.add(Set.of(_active.value)..remove(key));
        _log.log(
          'Removing ${task.group} from active download',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
    }
  }

  @override
  ValueStream<Set<DownloadChapterKey>> get activeDownloadStream =>
      _active.stream;
}
