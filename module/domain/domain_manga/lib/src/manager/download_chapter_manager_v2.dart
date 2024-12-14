import 'dart:developer';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart' hide Config;
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_active_download_use_case.dart';

class DownloadChapterManagerV2
    implements DownloadChapterUseCase, ListenActiveDownloadUseCase {
  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BehaviorSubject<Set<DownloadChapter>> _active;

  final _userAgent = 'Mozilla/5.0 '
      '(Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/127.0.0.0 '
      'Safari/537.36';

  static Future<DownloadChapterManagerV2> create({
    required BaseCacheManager cacheManager,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
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
    final database = fileDownloader.database;

    final runningDownloadRecords = await database.allRecordsWithStatus(
      TaskStatus.running,
    );
    final group = runningDownloadRecords.groupListsBy((record) => record.group);
    final activeDownload = group.keys.map(
      (key) => DownloadChapter.fromJsonString(key),
    );

    return DownloadChapterManagerV2._(
      cacheManager: cacheManager,
      fileDownloader: fileDownloader.registerCallbacks(
        taskNotificationTapCallback: (task, notificationType) => log(
          'Tap Notification for ${task.taskId} with $notificationType',
          name: 'DownloadChapterManagerV2',
          time: DateTime.now(),
        ),
      ),
      activeDownload: activeDownload.toSet(),
      getChapterUseCase: getChapterUseCase,
    );
  }

  DownloadChapterManagerV2._({
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required Set<DownloadChapter> activeDownload,
  })  : _fileDownloader = fileDownloader,
        _cacheManager = cacheManager,
        _getChapterUseCase = getChapterUseCase,
        _active = BehaviorSubject.seeded(activeDownload) {
    _init();
    fileDownloader.updates.distinct().listen(_onUpdate);
  }

  void _init() async {
    final records = await _fileDownloader.database.allRecordsWithStatus(
      TaskStatus.complete,
    );

    for (final record in records) {
      final task = record.task;
      if (task is DownloadTask) {
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

        if (path == null) continue;
        await _cacheManager.removeFile(record.task.url);
        await _cacheManager.putFile(
          record.task.url,
          await File(path).readAsBytes(),
        );
        log(
          'Adding ${record.task.url} - $path to cache',
          name: 'DownloadChapterManagerV2',
          time: DateTime.now(),
        );
      }
    }
  }

  void _onUpdate(TaskUpdate event) async {
    if (event is TaskStatusUpdate) {
      if (event.status != TaskStatus.complete) return;
      final task = event.task;
      if (task is DownloadTask) {
        final path = await _fileDownloader.moveToSharedStorage(
          task,
          SharedStorage.downloads,
          directory: 'Mangastash/${task.directory}',
        );
        if (path == null) return;
        await _cacheManager.removeFile(event.task.url);
        await _cacheManager.putFile(
          event.task.url,
          await File(path).readAsBytes(),
        );
        log(
          'Adding ${event.task.url} - $path to cache',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
      final records = await _fileDownloader.database.allRecords(
        group: task.group,
      );
      final finalState = [TaskStatus.complete, TaskStatus.canceled, TaskStatus.notFound, TaskStatus.failed];
      final nonFinalStateRecords = records.where(
        (task) => !finalState.contains(task.status),
      );
      if (nonFinalStateRecords.isNotEmpty) return;
      final downloadChapter = DownloadChapter.fromJsonString(task.group);
      _active.add(Set.of(_active.value)..remove(downloadChapter));
      log(
        'Removing ${task.group} from active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }

    if (event is TaskProgressUpdate) {
      log(
        'Receive TaskProgressUpdate for ${event.task.taskId}: ${event.progress} %',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }

  @override
  void downloadChapter({required DownloadChapter key}) async {
    final keyString = key.toJsonString();

    final result = await _getChapterUseCase().execute(
      chapterId: key.chapter?.id,
      source: key.manga?.source,
      mangaId: key.manga?.id,
    );

    if (result is Success<MangaChapter>) {

      _active.add(Set.of(_active.value)..add(key));
      log(
        'Adding $keyString to active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      log(
        'Success fetching chapter images for $keyString',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      final images = result.data.images ?? [];
      final title = key.manga?.title;
      final chapter = key.chapter?.numChapter;

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

      for (final (index, url) in images.indexed) {
        final extension = url.split('.').lastOrNull;

        if (title == null || chapter == null || extension == null) continue;

        final task = DownloadTask(
          url: url,
          headers: {HttpHeaders.userAgentHeader: _userAgent},
          baseDirectory: BaseDirectory.applicationDocuments,
          updates: Updates.statusAndProgress,
          directory: '$title/$chapter',
          filename: '${index + 1}.$extension',
          retries: 3,
          group: keyString,
          creationTime: DateTime.now(),
          requiresWiFi: true,
        );

        final result = await _fileDownloader.enqueue(task);

        final text = result ? 'Success' : 'Failed';

        log(
          '$text enqueue download task for $url',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }

      final cover = key.manga?.coverUrl;
      final coverExt = cover?.split('.').lastOrNull;

      final records = await _fileDownloader.database.allRecords(
        group: keyString,
      );

      final recordCover = records.firstWhereOrNull((e) => e.task.url == cover);
      if (recordCover == null && cover != null && coverExt != null) {
        final result = await _fileDownloader.enqueue(
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
          ),
        );

        final text = result ? 'Success' : 'Failed';

        log(
          '$text enqueue download task for $cover',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
    }

    if (result is Error<MangaChapter>) {
      log(
        'Failed fetching chapter images for ${key.hashCode} | ${result.error}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }

  @override
  ValueStream<Set<DownloadChapter>> get activeDownloadStream => _active.stream;
}
