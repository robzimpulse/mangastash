import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/cupertino.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:rxdart/rxdart.dart';

import '../mixin/generate_task_id_mixin.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_download_progress_use_case.dart';

typedef Key = DownloadChapterKey;
typedef Update = Map<String, double>;
typedef Progress = DownloadChapterProgress;

class DownloadProgressManager
    with GenerateTaskIdMixin, UserAgentMixin
    implements ListenDownloadProgressUseCase {
  final BehaviorSubject<Map<Key, Update>> _progress;
  final BehaviorSubject<Map<String, Task>> _tasks;
  final BehaviorSubject<List<FetchChapterJobDrift>> _jobs;
  final FetchChapterJobDao _fetchChapterJobDao;
  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final LogBox _log;

  late final StreamSubscription _streamSubscription;
  late final StreamSubscription _streamSubscription2;
  bool _isFetchingChapter = false;

  static Future<DownloadProgressManager> create({
    required FetchChapterJobDao fetchChapterJobDao,
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required LogBox log,
  }) async {
    final records = await fileDownloader.database.allRecords();

    return DownloadProgressManager(
      fileDownloader: fileDownloader,
      cacheManager: cacheManager,
      fetchChapterJobDao: fetchChapterJobDao,
      getChapterUseCase: getChapterUseCase,
      log: log,
      tasks: Map.fromEntries(records.map((e) => MapEntry(e.taskId, e.task))),
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
    required Map<String, Task> tasks,
    required Map<Key, Update> progress,
    required FetchChapterJobDao fetchChapterJobDao,
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required List<TaskRecord> completeRecords,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
  })  : _log = log,
        _cacheManager = cacheManager,
        _fileDownloader = fileDownloader,
        _tasks = BehaviorSubject.seeded(tasks),
        _jobs = BehaviorSubject.seeded([]),
        _fetchChapterJobDao = fetchChapterJobDao,
        _getChapterUseCase = getChapterUseCase,
        _progress = BehaviorSubject.seeded(progress) {
    _streamSubscription = _fileDownloader.updates.distinct().listen(_onUpdate);
    _streamSubscription2 = _jobs.distinct().listen(_onFetch);
    _jobs.addStream(fetchChapterJobDao.listen());
    for (final record in completeRecords) {
      _moveFileToSharedStorage(status: record.status, task: record.task);
    }
  }

  Future<void> dispose() async {
    await _streamSubscription.cancel();
    await _streamSubscription2.cancel();
  }

  Future<void> _moveFileToSharedStorage({
    required TaskStatus status,
    required Task task,
  }) async {
    if (task is! DownloadTask) return;
    if (status != TaskStatus.complete) return;

    _log.log(
      'Move image to shared storage',
      extra: {
        'url': task.url,
        'pathInSharedStorage': await _fileDownloader.pathInSharedStorage(
          task.filename,
          SharedStorage.downloads,
          directory: 'Mangastash/${task.directory}',
        ),
        'moveToSharedStorage': await _fileDownloader.moveToSharedStorage(
          task,
          SharedStorage.downloads,
          directory: 'Mangastash/${task.directory}',
        ),
        'task': task.toJson().toString(),
      },
      name: runtimeType.toString(),
    );
  }

  void _onFetch(List<FetchChapterJobDrift> jobs) async {
    final job = jobs.firstOrNull;
    if (job == null || _isFetchingChapter) return;

    _isFetchingChapter = true;

    final result = await _getChapterUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
      chapterId: job.chapterId,
    );

    _isFetchingChapter = false;

    if (result is Success<MangaChapter>) {
      _log.log(
        'Success fetch chapter',
        extra: {
          'manga_id': job.mangaId,
          'chapter_id': job.chapterId,
          'source': job.source,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );
      _fetchChapterJobDao.remove(job.toCompanion(true));

      final key = DownloadChapterKey.fromDrift(job);
      final groupId = key.toJsonString();
      final images = result.data.images ?? [];
      final title = key.mangaTitle;
      final chapter = key.chapterNumber;
      final cover = key.mangaCoverUrl;
      final extension = cover?.split('.').lastOrNull;
      final info = '${key.mangaTitle} - chapter ${key.chapterNumber}';

      _fileDownloader.configureNotificationForGroup(
        groupId,
        running: TaskNotification(
          'Downloading $title chapter $chapter',
          '{numFinished} out of {numTotal}',
        ),
        complete: TaskNotification(
          "Finish Downloading $title chapter $chapter",
          "Loaded {numTotal} files",
        ),
        error: const TaskNotification(
          'Error',
          '{numFailed}/{numTotal} failed',
        ),
        progressBar: false,
        groupNotificationId: groupId,
      );

      final List<DownloadTask> tasks = [];
      if (cover != null && extension != null && title != null) {
        final filename = 'cover.$extension';

        tasks.add(
          DownloadTask(
            taskId: generateTaskId(
              url: cover,
              directory: title,
              filename: filename,
              group: groupId,
            ),
            url: cover,
            headers: {HttpHeaders.userAgentHeader: userAgent},
            baseDirectory: BaseDirectory.applicationDocuments,
            updates: Updates.statusAndProgress,
            directory: title,
            filename: filename,
            retries: 3,
            group: groupId,
            creationTime: DateTime.now(),
            requiresWiFi: true,
            allowPause: true,
          ),
        );
      }

      for (final (index, url) in images.indexed) {
        final extension = url.split('.').lastOrNull;

        if (title == null || chapter == null || extension == null) continue;

        final directory = '$title/$chapter';
        final filename = '${index + 1}.$extension';

        tasks.add(
          DownloadTask(
            taskId: generateTaskId(
              url: url,
              directory: directory,
              filename: filename,
              group: groupId,
            ),
            url: url,
            headers: {HttpHeaders.userAgentHeader: userAgent},
            baseDirectory: BaseDirectory.applicationDocuments,
            updates: Updates.statusAndProgress,
            directory: directory,
            filename: filename,
            retries: 3,
            group: groupId,
            creationTime: DateTime.now(),
            allowPause: true,
            requiresWiFi: true,
          ),
        );
      }

      for (final task in tasks) {
        await _fileDownloader.enqueue(task);

        _log.log(
          '[$info] Success enqueue task',
          extra: {
            'id': task.taskId,
            'url': task.url,
            'base_directory': task.baseDirectory.toString(),
            'directory': task.directory,
            'filename': task.filename,
            'group': task.group,
            'headers': task.headers.toString(),
          },
          name: runtimeType.toString(),
        );
      }
    }

    if (result is Error<MangaChapter>) {
      _log.log(
        'Failed fetch chapter',
        extra: {
          'manga_id': job.mangaId,
          'chapter_id': job.chapterId,
          'source': job.source,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }
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
