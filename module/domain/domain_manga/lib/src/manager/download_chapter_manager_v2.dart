import 'dart:developer';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart' hide Config;
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';

import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';

class DownloadChapterManagerV2 implements DownloadChapterUseCase {
  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;

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
        (Config.holdingQueue, (5, null, null)),
      ],
      androidConfig: [
        (Config.useCacheDir, Config.whenAble),
      ],
      iOSConfig: [
        (Config.localize, {'Cancel': 'StopIt'}),
      ],
    );

    await Future.wait([cacheManager.emptyCache(), fileDownloader.trackTasks()]);

    final records = await fileDownloader.database.allRecordsWithStatus(
      TaskStatus.complete,
    );

    for (final record in records) {
      final task = record.task;
      if (task is DownloadTask) {
        final path = await fileDownloader.moveToSharedStorage(
              task,
              SharedStorage.downloads,
              directory: 'Mangastash/${task.directory}',
            ) ??
            await fileDownloader.pathInSharedStorage(
              task.filename,
              SharedStorage.downloads,
              directory: 'Mangastash/${task.directory}',
            );
        if (path == null) continue;
        cacheManager.putFile(
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

    return DownloadChapterManagerV2._(
      cacheManager: cacheManager,
      fileDownloader: fileDownloader.registerCallbacks(
        taskNotificationTapCallback: (task, notificationType) => log(
          'Tap Notification for  ${task.taskId} with $notificationType',
          name: 'DownloadChapterManagerV2',
          time: DateTime.now(),
        ),
      ),
      getChapterUseCase: getChapterUseCase,
    );
  }

  DownloadChapterManagerV2._({
    required FileDownloader fileDownloader,
    required BaseCacheManager cacheManager,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
  })  : _fileDownloader = fileDownloader,
        _cacheManager = cacheManager,
        _getChapterUseCase = getChapterUseCase {
    fileDownloader.updates.distinct().listen(_onUpdate);
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
        _cacheManager.putFile(
          event.task.url,
          await File(path).readAsBytes(),
        );
        log(
          'Adding ${event.task.url} - $path to cache',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
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
    final result = await _getChapterUseCase().execute(
      chapterId: key.chapter?.id,
      source: key.manga?.source,
      mangaId: key.manga?.id,
    );

    if (result is Success<MangaChapter>) {
      log(
        'Success fetching chapter images for ${key.hashCode}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      final images = result.data.images ?? [];
      final title = key.manga?.title;
      final chapter = key.chapter?.numChapter;

      _fileDownloader.configureNotificationForGroup(
        '${key.hashCode}',
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
        groupNotificationId: '${key.hashCode}',
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
          group: '${key.hashCode}',
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
    }

    if (result is Error<MangaChapter>) {
      log(
        'Failed fetching chapter images for ${key.hashCode} | ${result.error}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }
}
