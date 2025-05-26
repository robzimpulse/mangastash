import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/tables/job_tables.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';

class JobManager {
  final BehaviorSubject<List<JobDrift>> _jobs = BehaviorSubject.seeded([]);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final JobDao _jobDao;
  final LogBox _log;

  bool _isFetching = false;

  late final StreamSubscription _streamSubscription;

  // TODO: add how to enqueue a job to populate manga / chapter data in background
  JobManager({
    required LogBox log,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required JobDao jobDao,
  })  : _log = log,
        _getMangaUseCase = getMangaUseCase,
        _getChapterUseCase = getChapterUseCase,
        _jobDao = jobDao {
    _streamSubscription = _jobs.distinct().listen(_onData);
    _jobs.addStream(_jobDao.listen());
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _onData(List<JobDrift> jobs) async {
    final job = jobs.firstOrNull;
    if (job == null || _isFetching) return;

    _isFetching = true;

    switch (job.type) {
      case JobType.manga:
        await _fetchManga(job);
      case JobType.chapter:
        await _fetchChapter(job);
    }
  }

  Future<void> _fetchChapter(JobDrift job) async {
    final result = await _getChapterUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
      chapterId: job.chapterId,
    );

    _isFetching = false;

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
      _jobDao.remove(job.toCompanion(true));
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

  Future<void> _fetchManga(JobDrift job) async {
    final mangaId = job.mangaId;

    if (mangaId == null) {
      _isFetching = false;
      _jobDao.remove(job.toCompanion(true));
      return;
    }

    final result = await _getMangaUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: mangaId,
    );

    _isFetching = false;

    if (result is Success<Manga>) {
      _log.log(
        'Success fetch manga',
        extra: {
          'manga_id': job.mangaId,
          'chapter_id': job.chapterId,
          'source': job.source,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );
      _jobDao.remove(job.toCompanion(true));
    }

    if (result is Error<Manga>) {
      _log.log(
        'Failed fetch manga',
        extra: {
          'manga_id': job.mangaId,
          'chapter_id': job.chapterId,
          'source': job.source,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }
    _isFetching = false;
  }
}
