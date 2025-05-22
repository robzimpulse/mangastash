import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../../domain_manga.dart';
import '../../mixin/generate_task_id_mixin.dart';
import 'get_chapter_use_case.dart';

class DownloadChapterUseCase with GenerateTaskIdMixin, UserAgentMixin {
  final FileDownloader _fileDownloader;
  final GetChapterUseCase _getChapterUseCase;
  final LogBox _log;

  DownloadChapterUseCase({
    required FileDownloader fileDownloader,
    required GetChapterUseCase getChapterUseCase,
    required LogBox log,
  })  : _fileDownloader = fileDownloader,
        _getChapterUseCase = getChapterUseCase,
        _log = log;

  Future<void> execute({required DownloadChapterKey key}) async {
    final groupId = key.toJsonString();
    final info = '${key.mangaTitle} - chapter ${key.chapterNumber}';

    final result = await _getChapterUseCase.execute(
      chapterId: key.chapterId,
      source: key.mangaSource,
      mangaId: key.mangaId,
    );

    if (result is Success<MangaChapter>) {
      _log.log(
        '[$info] Success fetching chapter images',
        name: runtimeType.toString(),
      );

      final images = result.data.images ?? [];
      final title = key.mangaTitle;
      final chapter = key.chapterNumber;

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

      final cover = key.mangaCoverUrl;
      final extension = cover?.split('.').lastOrNull;
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

      final records = await _fileDownloader.database.recordsForIds(
        tasks.map((task) => task.taskId),
      );
      final recordKeyedByTaskId = Map.fromEntries(
        records.map((e) => MapEntry(e.taskId, e)),
      );
      for (final task in tasks) {
        if (recordKeyedByTaskId[task.taskId] != null) continue;
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
        'Failed fetching chapter images for ${key.hashCode} | ${result.error}',
        name: runtimeType.toString(),
      );
    }
  }
}
