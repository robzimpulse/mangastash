import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:rxdart/rxdart.dart';

import '../mixin/generate_task_id_mixin.dart';
import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/prefetch_chapter_use_case.dart';
import '../use_case/chapter/search_chapter_use_case.dart';
import '../use_case/library/listen_prefetch_use_case.dart';
import '../use_case/manga/download_manga_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';
import '../use_case/manga/prefetch_manga_use_case.dart';

class JobManager
    with GenerateTaskIdMixin, UserAgentMixin
    implements
        PrefetchMangaUseCase,
        PrefetchChapterUseCase,
        DownloadChapterUseCase,
        DownloadMangaUseCase,
        ListenPrefetchUseCase {
  final BehaviorSubject<List<JobDetail>> _jobs = BehaviorSubject.seeded([]);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final ValueGetter<SearchChapterUseCase> _searchChapterUseCase;
  final FileDownloader _fileDownloader;
  final BaseCacheManager _cacheManager;
  final JobDao _jobDao;
  final LogBox _log;

  bool _isFetching = false;

  late final StreamSubscription _streamSubscription;

  JobManager({
    required LogBox log,
    required JobDao jobDao,
    required BaseCacheManager cacheManager,
    required FileDownloader fileDownloader,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required ValueGetter<SearchChapterUseCase> searchChapterUseCase,
  })  : _log = log,
        _jobDao = jobDao,
        _fileDownloader = fileDownloader,
        _cacheManager = cacheManager,
        _getMangaUseCase = getMangaUseCase,
        _getChapterUseCase = getChapterUseCase,
        _searchChapterUseCase = searchChapterUseCase {
    _streamSubscription = _jobs.distinct().listen(_onData);
    _jobs.addStream(jobDao.listen());
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _onData(List<JobDetail> jobs) async {
    final job = jobs.firstOrNull;
    if (job == null || _isFetching) return;

    _isFetching = true;

    switch (job.type) {
      case JobTypeEnum.manga:
        await _fetchManga(job);
      case JobTypeEnum.chapters:
        await _fetchAllChapter(job);
      case JobTypeEnum.chapter:
        await _fetchChapter(job);
      case JobTypeEnum.image:
        await _fetchImage(job);
      case JobTypeEnum.downloadChapter:
        await _downloadChapter(job);
    }

    _isFetching = false;

    _jobDao.remove(job.id);
  }

  Future<void> _fetchManga(JobDetail job) async {
    final mangaId = job.manga?.id;

    if (mangaId == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': 'No Manga ID',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final source = job.manga?.source?.let((e) => MangaSourceEnum.fromValue(e));

    final result = await _getMangaUseCase().execute(
      source: source,
      mangaId: mangaId,
    );

    if (result is Error<Manga>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }

    if (result is Success<Manga>) {
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );
    }
  }

  Future<void> _fetchChapter(JobDetail job) async {
    final mangaId = job.manga?.id;
    final chapterId = job.chapter?.id;

    if (mangaId == null || chapterId == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': 'No Manga ID or Chapter ID',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final source = job.manga?.source?.let((e) => MangaSourceEnum.fromValue(e));

    final result = await _getChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      chapterId: chapterId,
    );

    if (result is Error<MangaChapter>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }

    if (result is Success<MangaChapter>) {
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );

      final images = await _jobDao.getImageIds(result.data.images ?? []);
      for (final image in images) {
        await _jobDao.add(
          JobTablesCompanion.insert(
            mangaId: Value(mangaId),
            chapterId: Value(chapterId),
            imageId: Value(image.id),
            type: JobTypeEnum.image,
          ),
        );
      }
    }
  }

  Future<void> _fetchAllChapter(
    JobDetail job, {
    SearchChapterParameter parameter = const SearchChapterParameter(
      offset: 0,
      page: 1,
      limit: 100,
    ),
  }) async {
    final mangaId = job.manga?.id;

    if (mangaId == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': 'No Manga ID',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final source = job.manga?.source?.let((e) => MangaSourceEnum.fromValue(e));

    final result = await _searchChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      parameter: parameter,
    );

    if (result is Error<Pagination<MangaChapter>>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }

    if (result is Success<Pagination<MangaChapter>>) {
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'parameter': parameter,
          'data': result.data.toJson((e) => e.toJson()),
        },
        name: runtimeType.toString(),
      );

      if (result.data.hasNextPage == true) {
        await _fetchAllChapter(
          job,
          parameter: SearchChapterParameter(
            offset: (parameter.offset ?? 0) + (parameter.limit ?? 0),
            page: (parameter.page ?? 1) + 1,
            limit: 100,
          ),
        );
      }
    }
  }

  Future<void> _downloadChapter(JobDetail job) async {
    final mangaId = job.manga?.id;
    final chapterId = job.chapter?.id;

    if (mangaId == null || chapterId == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': 'No Manga ID or Chapter ID',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final source = job.manga?.source?.let((e) => MangaSourceEnum.fromValue(e));

    final result = await _getChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      chapterId: chapterId,
    );

    if (result is Error<MangaChapter>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }

    if (result is Success<MangaChapter>) {
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );

      final key = DownloadChapterKey.create(
        manga: job.manga?.let((e) => Manga.fromDrift(e)),
        chapter: job.chapter?.let((e) => MangaChapter.fromDrift(e)),
      );
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
  }

  Future<void> _fetchImage(JobDetail job) async {
    final url = job.image?.webUrl;
    if (url == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let(
            (e) => MangaChapter.fromDrift(e).toJson(),
          ),
          'image': job.image?.webUrl,
          'error': 'No Image URL',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final existing = (await _cacheManager.getFileFromCache(url))?.file;

    final path = existing.or(
      await _cacheManager.getSingleFile(
        url,
        headers: {HttpHeaders.userAgentHeader: userAgent},
      ),
    );

    _log.log(
      'Success execute job ${job.id} - ${job.type}',
      extra: {
        'id': job.id,
        'type': job.type,
        'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
        'chapter': job.chapter?.let(
          (e) => MangaChapter.fromDrift(e).toJson(),
        ),
        'image': job.image?.webUrl,
        'data': path.uri.toString(),
      },
      name: runtimeType.toString(),
    );
  }

  @override
  void prefetchChapters({
    required String mangaId,
    required MangaSourceEnum source,
  }) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.chapters,
        source: Value(mangaId),
        mangaId: Value(mangaId),
      ),
    );
  }

  @override
  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  }) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.chapter,
        source: Value(source.value),
        mangaId: Value(mangaId),
        chapterId: Value(chapterId),
      ),
    );
  }

  @override
  void prefetchManga({
    required String mangaId,
    required MangaSourceEnum source,
  }) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.manga,
        source: Value(source.value),
        mangaId: Value(mangaId),
      ),
    );
  }

  @override
  void downloadChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  }) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.downloadChapter,
        source: Value(source.value),
        mangaId: Value(mangaId),
        chapterId: Value(chapterId),
      ),
    );
  }

  @override
  void downloadManga({
    required String mangaId,
    required MangaSourceEnum source,
  }) {
    // TODO: download manga without chapter id
    // _jobDao.add(
    //   JobTablesCompanion.insert(
    //     type: JobTypeEnum.download,
    //     source: Value(source.value),
    //     mangaId: Value(mangaId),
    //   ),
    // );
  }

  @override
  Stream<Map<String, Set<String>>> get prefetchedStream {
    final stream = _jobs.map((e) => e.groupListsBy((e) => e.manga?.id));
    return stream.map(
      (e) {
        final data = <String, Set<String>>{};
        for (final entry in e.entries) {
          final value = entry.value.map((e) => e.chapter?.id).nonNulls;
          entry.key?.let(
            (key) => data.update(
              key,
              (old) => {...value},
              ifAbsent: () => {...value},
            ),
          );
        }
        return data;
      },
    );
  }
}
