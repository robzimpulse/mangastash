import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart' hide Config;
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_progress_use_case.dart';
import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_active_download_use_case.dart';

class DownloadChapterManager
    implements
        DownloadChapterUseCase,
        ListenActiveDownloadUseCase,
        DownloadChapterProgressUseCase {
  static const _finalStateTask = [
    TaskStatus.complete,
    TaskStatus.canceled,
    TaskStatus.notFound,
    TaskStatus.failed,
  ];

  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BehaviorSubject<Set<DownloadChapterKey>> _active;
  final Map<DownloadChapterKey, BehaviorSubject<(int, double)>> _progress;
  final LogBox _log;

  StreamSubscription? _streamSubscription;

  final _userAgent = 'Mozilla/5.0 '
      '(Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/127.0.0.0 '
      'Safari/537.36';

  static Future<DownloadChapterManager> create({
    required BaseCacheManager cacheManager,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required LogBox log,
  }) async {
    final fileDownloader = FileDownloader();

    await fileDownloader.configure(
      globalConfig: [
        (Config.requestTimeout, const Duration(minutes: 1)),
        (Config.resourceTimeout, const Duration(minutes: 10)),
        (Config.holdingQueue, (null, 5, null)),
      ],
      androidConfig: [
        (Config.useCacheDir, Config.whenAble),
      ],
      iOSConfig: [
        (Config.excludeFromCloudBackup, Config.always),
      ],
    );

    await fileDownloader.trackTasks();
    final records = await fileDownloader.database.allRecords();

    return DownloadChapterManager._(
      cacheManager: cacheManager,
      getChapterUseCase: getChapterUseCase,
      log: log,
      fileDownloader: fileDownloader.registerCallbacks(
        taskNotificationTapCallback: (task, notificationType) => log.log(
          'Tap Notification for ${task.taskId} with $notificationType',
          name: 'DownloadChapterManagerV2',
          time: DateTime.now(),
        ),
      ),
      activeDownloadKey: records
          .where((record) => record.status == TaskStatus.running)
          .groupListsBy((record) => record.group)
          .keys
          .map((key) => DownloadChapterKey.fromJsonString(key))
          .toSet(),
      completeRecords: records
          .where((record) => record.status == TaskStatus.complete)
          .toList(),
      initialProgress: records.groupFoldBy<DownloadChapterKey, (int, double)>(
        (record) => DownloadChapterKey.fromJsonString(record.group),
        (result, current) {
          final total = (result?.$1 ?? 0) + 1;
          return (total, (result?.$2 ?? 0.0) + current.progress);
        },
      ).map((key, value) => MapEntry(key, (value.$1, value.$2 / value.$1))),
    );
  }

  DownloadChapterManager._({
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required LogBox log,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required Set<DownloadChapterKey> activeDownloadKey,
    required List<TaskRecord> completeRecords,
    required Map<DownloadChapterKey, (int, double)> initialProgress,
  })  : _fileDownloader = fileDownloader,
        _cacheManager = cacheManager,
        _log = log,
        _getChapterUseCase = getChapterUseCase,
        _active = BehaviorSubject.seeded(activeDownloadKey),
        _progress = Map.of(initialProgress).map(
          (key, value) => MapEntry(key, BehaviorSubject.seeded(value)),
        ) {
    for (final record in completeRecords) {
      final task = record.task;
      if (task is! DownloadTask) continue;
      _moveFileToSharedStorage(task: task);
    }
    _streamSubscription = fileDownloader.updates.distinct().listen(_onUpdate);
  }

  void dispose() {
    _streamSubscription?.cancel();
  }

  void _onUpdate(TaskUpdate event) async {
    final key = DownloadChapterKey.fromJsonString(event.task.group);
    final task = event.task;
    if (event is TaskStatusUpdate) {
      if (event.status != TaskStatus.complete) return;
      if (task is! DownloadTask) return;
      await _moveFileToSharedStorage(task: task);

      final records = await _fileDownloader.database.allRecords(
        group: task.group,
      );
      final nonFinalStateRecords = records.where(
        (task) => !_finalStateTask.contains(task.status),
      );
      if (nonFinalStateRecords.isNotEmpty) return;
      _active.add(Set.of(_active.value)..remove(key));
      _log.log(
        'Removing ${task.group} from active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }

    if (event is TaskProgressUpdate) {
      final records = await _fileDownloader.database.allRecords(
        group: task.group,
      );
      final overallProgress = records.fold<(int, double)>(
        (records.length, 0.0),
        (result, current) {
          return (records.length, result.$2 + current.progress);
        },
      );
      final progress = _progress.putIfAbsent(
        key,
        () => BehaviorSubject.seeded((records.length, 0.0)),
      );
      progress.add(
        (overallProgress.$1, overallProgress.$2 / overallProgress.$1),
      );
      _log.log(
        'Receive TaskProgressUpdate for ${event.task.taskId}: ${event.progress} %',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }

  @override
  Future<void> downloadChapter({required DownloadChapterKey key}) async {
    final keyString = key.toJsonString();

    final result = await _getChapterUseCase().execute(
      chapterId: key.chapterId,
      source: key.mangaSource,
      mangaId: key.mangaId,
    );

    if (result is Success<MangaChapter>) {
      _active.add(Set.of(_active.value)..add(key));
      _log.log(
        'Adding $keyString to active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      _log.log(
        'Success fetching chapter images for $keyString',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      final images = result.data.images ?? [];
      final title = key.mangaTitle;
      final chapter = key.chapterNumber;

      _fileDownloader.configureNotificationForGroup(
        keyString,
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
        groupNotificationId: keyString,
      );

      final List<DownloadTask> tasks = [];
      for (final (index, url) in images.indexed) {
        final extension = url.split('.').lastOrNull;

        if (title == null || chapter == null || extension == null) continue;

        tasks.add(
          DownloadTask(
            url: url,
            headers: {HttpHeaders.userAgentHeader: _userAgent},
            baseDirectory: BaseDirectory.applicationDocuments,
            updates: Updates.statusAndProgress,
            directory: '$title/$chapter',
            filename: '${index + 1}.$extension',
            retries: 3,
            group: keyString,
            creationTime: DateTime.now(),
            allowPause: true,
            requiresWiFi: true,
          ),
        );
      }

      final cover = key.mangaCoverUrl;
      final coverExt = cover?.split('.').lastOrNull;
      final records = await _fileDownloader.database.allRecords(
        group: keyString,
      );
      final recordCover = records.firstWhereOrNull((e) => e.task.url == cover);
      if (recordCover == null && cover != null && coverExt != null) {
        tasks.add(
          DownloadTask(
            url: cover,
            headers: {HttpHeaders.userAgentHeader: _userAgent},
            baseDirectory: BaseDirectory.applicationDocuments,
            updates: Updates.statusAndProgress,
            directory: '$title',
            filename: 'cover.$coverExt',
            retries: 5,
            group: keyString,
            creationTime: DateTime.now(),
            requiresWiFi: true,
            allowPause: true,
          ),
        );
      }

      await Future.wait(tasks.map((e) => _fileDownloader.enqueue(e)));
    }

    if (result is Error<MangaChapter>) {
      _log.log(
        'Failed fetching chapter images for ${key.hashCode} | ${result.error}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }

  @override
  ValueStream<Set<DownloadChapterKey>> get activeDownloadStream =>
      _active.stream;

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

    if (path == null) return;
    await _cacheManager.removeFile(task.url);
    await _cacheManager.putFile(
      task.url,
      await File(path).readAsBytes(),
    );
    _log.log(
      'Adding ${task.url} - $path to cache',
      name: 'DownloadChapterManagerV2',
      time: DateTime.now(),
    );
  }

  @override
  double downloadChapterProgress({required DownloadChapterKey key}) {
    return downloadChapterProgressStream(key: key).value.$2;
  }

  @override
  ValueStream<(int, double)> downloadChapterProgressStream({
    required DownloadChapterKey key,
  }) {
    return _progress
        .putIfAbsent(
          key,
          () => BehaviorSubject.seeded((0, 0.0)),
        )
        .stream;
  }
}
