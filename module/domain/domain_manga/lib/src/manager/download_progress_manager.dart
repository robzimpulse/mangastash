import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../mixin/generate_task_id_mixin.dart';
import '../use_case/download/listen_download_progress_use_case.dart';

typedef Key = DownloadChapterKey;
typedef Update = Map<String, double>;
typedef Progress = DownloadChapterProgress;

class DownloadProgressManager
    with GenerateTaskIdMixin, UserAgentMixin
    implements ListenDownloadProgressUseCase {
  final BehaviorSubject<Map<Key, Update>> _progress;
  final BehaviorSubject<Map<String, Task>> _tasks;
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
    final progress = records.groupFoldBy<Key?, Update>(
      (record) => Key.fromJsonString(record.group),
      (result, current) => (result != null)
          ? (Map.of(result)..[current.taskId] = current.progress)
          : {current.taskId: current.progress},
    );
    return DownloadProgressManager(
      fileDownloader: fileDownloader,
      cacheManager: cacheManager,
      log: log,
      tasks: Map.fromEntries(records.map((e) => MapEntry(e.taskId, e.task))),
      completeRecords: List.of(
        records.where((record) => record.status.isFinalState),
      ),
      progress: Map.fromEntries(
        progress.entries
            .map(
              (entry) {
                final key = entry.key;
                if (key == null) return null;
                return MapEntry(
                  key,
                  entry.value,
                );
              },
            )
            .nonNulls,
      ),
    );
  }

  DownloadProgressManager({
    required LogBox log,
    required Map<String, Task> tasks,
    required Map<Key, Update> progress,
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required List<TaskRecord> completeRecords,
  })  : _log = log,
        _cacheManager = cacheManager,
        _fileDownloader = fileDownloader,
        _tasks = BehaviorSubject.seeded(tasks),
        _progress = BehaviorSubject.seeded(progress) {
    _streamSubscription = _fileDownloader.updates.distinct().listen(_onUpdate);
    for (final record in completeRecords) {
      _moveFileToSharedStorage(status: record.status, task: record.task);
    }
  }

  Future<void> dispose() => _streamSubscription.cancel();

  Future<void> _moveFileToSharedStorage({
    required TaskStatus status,
    required Task task,
  }) async {
    if (task is! DownloadTask) return;
    if (status != TaskStatus.complete) return;

    final moveSharedStoragePath = await _fileDownloader.moveToSharedStorage(
      task,
      SharedStorage.downloads,
      directory: 'Mangastash/${task.directory}',
    );

    final pathInSharedStorage = await _fileDownloader.pathInSharedStorage(
      task.filename,
      SharedStorage.downloads,
      directory: 'Mangastash/${task.directory}',
    );

    final path = moveSharedStoragePath ?? pathInSharedStorage;

    _log.log(
      'Move image to shared storage',
      extra: {
        'url': task.url,
        'moveSharedStoragePath': moveSharedStoragePath,
        'pathInSharedStorage': pathInSharedStorage,
        'path': path,
        'task': task.toJson().toString(),
      },
      name: runtimeType.toString(),
    );

    if (path == null) return;

    await _cacheManager.removeFile(task.url);

    await _cacheManager.putFile(task.url, await File(path).readAsBytes());

    _log.log(
      'Adding image to cache',
      extra: {
        'url': task.url,
        'path': path,
        'task': task.toJson(),
      },
      name: runtimeType.toString(),
    );
  }

  void _onUpdate(TaskUpdate event) {
    _updateProgress(event);
    _updateTasks(event);
    _moveFile(event);
  }

  void _moveFile(TaskUpdate event) {
    if (event is! TaskStatusUpdate) return;
    _moveFileToSharedStorage(status: event.status, task: event.task);
  }

  void _updateTasks(TaskUpdate event) {
    final tasks = Map.of(_tasks.valueOrNull ?? <String, Task>{});

    tasks.update(
      event.task.taskId,
      (_) => event.task,
      ifAbsent: () => event.task,
    );

    _tasks.add(tasks);
  }

  void _updateProgress(TaskUpdate event) {
    final progress = Map.of(_progress.valueOrNull ?? <Key, Update>{});
    final key = Key.fromJsonString(event.task.group);
    if (key == null) return;
    progress.update(
      key,
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

    _log.log(
      'Updating Progress',
      extra: {
        'data': event.toString(),
      },
      name: runtimeType.toString(),
    );
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

  @override
  ValueStream<Map<String, String>> get filenames {
    return _tasks
        .map(
          (value) => value.map((key, value) => MapEntry(key, value.filename)),
        )
        .shareValue();
  }
}
