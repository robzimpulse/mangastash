import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/listen_download_progress_use_case.dart';

typedef Key = DownloadChapterKey;
typedef Update = Map<String, double>;
typedef Progress = DownloadChapterProgress;

class DownloadProgressManager implements ListenDownloadProgressUseCase {
  final BehaviorSubject<Map<Key, Update>> _progress;
  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final LogBox _log;

  late final StreamSubscription _streamSubscription;

  static Future<DownloadProgressManager> create({
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required LogBox log,
  }) async {
    final records = await fileDownloader.database.allRecords();

    return DownloadProgressManager(
      fileDownloader: fileDownloader,
      cacheManager: cacheManager,
      log: log,
      completeRecords: List.of(
        records.where((record) => record.status.isFinalState),
      ),
      progress: records.groupFoldBy<Key, Update>(
        (record) => Key.fromJsonString(record.group),
        (result, current) => (result != null)
            ? (Map.of(result)..[current.taskId] = current.progress)
            : {current.taskId: current.progress},
      ),
    );
  }

  DownloadProgressManager({
    required LogBox log,
    required Map<Key, Update> progress,
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required List<TaskRecord> completeRecords,
  })  : _log = log,
        _cacheManager = cacheManager,
        _fileDownloader = fileDownloader,
        _progress = BehaviorSubject.seeded(progress) {
    _streamSubscription = _fileDownloader.updates.distinct().listen(_onUpdate);
    for (final record in completeRecords) {
      final task = record.task;
      if (task is! DownloadTask) continue;
      _moveFileToSharedStorage(task: task);
    }
  }

  Future<void> dispose() async {
    await _streamSubscription.cancel();
  }

  Future<void> _moveFileToSharedStorage({
    required DownloadTask task,
  }) async {
    String? path = await _fileDownloader.pathInSharedStorage(
      task.filename,
      SharedStorage.downloads,
      directory: 'Mangastash/${task.directory}',
    );

    path ??= await _fileDownloader.moveToSharedStorage(
      task,
      SharedStorage.downloads,
      directory: 'Mangastash/${task.directory}',
    );

    _log.log(
      'Move ${task.url} - $path to shared storage',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );

    if (path == null) return;

    await _cacheManager.removeFile(task.url);

    await _cacheManager.putFile(
      task.url,
      await File(path).readAsBytes(),
    );

    _log.log(
      'Adding ${task.url} - $path to cache',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );
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

    _progress.add(progress);

    if (event is TaskStatusUpdate) {
      final task = event.task;
      if (task is DownloadTask) {
        _moveFileToSharedStorage(task: task);
      }
    }
  }

  @override
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> get all {
    final transformed = _progress.map(
      (value) => Map.of(value).map(
        (key, value) => MapEntry(key, DownloadChapterProgress(values: value)),
      ),
    );

    return transformed.shareValue();
  }

  @override
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> get active {
    return all
        .map(
          (value) => Map.of(value)
            ..removeWhere(
              (_, value) => value.progress == 1,
            ),
        )
        .shareValue();
  }

  @override
  ValueStream<Map<DownloadChapterKey, DownloadChapterProgress>> progress(
    List<DownloadChapterKey> keys,
  ) {
    return all
        .map(
          (value) => Map.of(value)
            ..removeWhere(
              (key, _) => keys.contains(key),
            ),
        )
        .shareValue();
  }
}
