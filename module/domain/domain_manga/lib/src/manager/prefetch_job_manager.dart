import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/tables/prefetch_job_tables.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_prefetch_chapter_use_case.dart';
import '../use_case/chapter/prefetch_chapter_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';
import '../use_case/manga/listen_prefetch_manga_use_case.dart';
import '../use_case/manga/prefetch_manga_use_case.dart';

class PrefetchJobManager
    implements
        PrefetchMangaUseCase,
        PrefetchChapterUseCase,
        ListenPrefetchChapterUseCase,
        ListenPrefetchMangaUseCase {
  final BehaviorSubject<List<PrefetchJobDrift>> _jobs =
      BehaviorSubject.seeded([]);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final PrefetchJobDao _prefetchJobDao;
  final LogBox _log;

  bool _isFetching = false;

  late final StreamSubscription _streamSubscription;

  PrefetchJobManager({
    required LogBox log,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required PrefetchJobDao prefetchJobDao,
  })  : _log = log,
        _getMangaUseCase = getMangaUseCase,
        _getChapterUseCase = getChapterUseCase,
        _prefetchJobDao = prefetchJobDao {
    _streamSubscription = _jobs.distinct().listen(_onData);
    _jobs.addStream(prefetchJobDao.listen());
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _onData(List<PrefetchJobDrift> jobs) async {
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

  Future<void> _fetchChapter(PrefetchJobDrift job) async {
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
      _prefetchJobDao.remove(job.toCompanion(true));
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

  Future<void> _fetchManga(PrefetchJobDrift job) async {
    final result = await _getMangaUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
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
      _prefetchJobDao.remove(job.toCompanion(true));
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

  @override
  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  }) {
    _prefetchJobDao.add(
      PrefetchJobTablesCompanion.insert(
        type: JobType.chapter,
        source: source.value,
        mangaId: mangaId,
        chapterId: Value(chapterId),
      ),
    );
  }

  @override
  void prefetchManga({
    required String mangaId,
    required MangaSourceEnum source,
  }) {
    _prefetchJobDao.add(
      PrefetchJobTablesCompanion.insert(
        type: JobType.manga,
        source: source.value,
        mangaId: mangaId,
      ),
    );
  }

  @override
  Stream<List<String>> get listenPrefetchedChapter {
    return _jobs.map(
      (event) => [
        ...event
            .where((e) => e.type == JobType.manga)
            .map((e) => e.chapterId)
            .nonNulls,
      ],
    );
  }

  @override
  Stream<List<String>> get listenPrefetchedManga {
    return _jobs.map(
      (event) => [
        ...event.where((e) => e.type == JobType.manga).map((e) => e.mangaId),
      ],
    );
  }
}
