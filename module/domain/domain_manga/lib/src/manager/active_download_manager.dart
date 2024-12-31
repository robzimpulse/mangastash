import 'dart:async';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/listen_active_download_use_case.dart';

typedef Key = DownloadChapterKey;
typedef Update = Map<String, double>;
typedef Progress = DownloadChapterProgress;

class ActiveDownloadManager implements ListenActiveDownloadUseCase {
  final BehaviorSubject<Map<Key, Update>> _progress;
  final FileDownloader _fileDownloader;
  final LogBox _log;

  late final StreamSubscription _streamSubscription;

  static Future<ActiveDownloadManager> create({
    required FileDownloader fileDownloader,
    required LogBox log,
  }) async {
    final records = await fileDownloader.database.allRecords();

    return ActiveDownloadManager(
      fileDownloader: fileDownloader,
      log: log,
      progress: records.groupFoldBy<Key, Update>(
        (record) => Key.fromJsonString(record.group),
        (result, current) => (result != null)
            ? (Map.of(result)..[current.taskId] = current.progress)
            : {current.taskId: current.progress},
      ),
    );
  }

  ActiveDownloadManager({
    required Map<Key, Update> progress,
    required FileDownloader fileDownloader,
    required LogBox log,
  })  : _progress = BehaviorSubject.seeded(progress),
        _log = log,
        _fileDownloader = fileDownloader {
    _streamSubscription = _fileDownloader.updates.distinct().listen(_onUpdate);
  }

  Future<void> dispose() async {
    await _streamSubscription.cancel();
  }

  void _onUpdate(TaskUpdate event) async {
    final progress = Map.of(_progress.valueOrNull ?? <Key, Update>{});

    progress.update(
      Key.fromJsonString(event.task.group),
      (old) {
        final data = Map.of(old);
        data.update(
          event.task.taskId,
          (oldData) {
            if (event is TaskStatusUpdate) {
              return event.status == TaskStatus.complete ? 1 : 0;
            }
            if (event is TaskProgressUpdate) {
              return max(event.progress, oldData);
            }
            return 0;
          },
          ifAbsent: () {
            if (event is TaskStatusUpdate) {
              return event.status == TaskStatus.complete ? 1 : 0;
            }
            if (event is TaskProgressUpdate) {
              return event.progress;
            }
            return 0;
          },
        );
        return data;
      },
      ifAbsent: () {
        final data = <String, double>{};
        if (event is TaskStatusUpdate) {
          data[event.task.taskId] = 1;
        }
        if (event is TaskProgressUpdate) {
          data[event.task.taskId] = event.progress;
        }
        return data;
      },
    );

    _log.log(
      'Updating new progress',
      name: '_onUpdate',
      time: DateTime.now(),
    );

    _progress.add(progress);
  }

  @override
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>>
      get activeDownloadStream {
    return _progress
        .map(
          (value) => Map.of(value)
            ..removeWhere(
              (key, value) => (value.isEmpty)
                  ? false
                  : (value.values.sum / value.values.length) == 1,
            ),
        )
        .map(
          (value) => Map.of(value).map(
            (key, value) => MapEntry(
              key,
              DownloadChapterProgress(
                total: value.length,
                progress: value.values.sum / value.length,
              ),
            ),
          ),
        )
        .shareValue();
  }
}
