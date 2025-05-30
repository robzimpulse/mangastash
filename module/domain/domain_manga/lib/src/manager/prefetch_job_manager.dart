import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/prefetch_chapter_use_case.dart';
import '../use_case/chapter/search_chapter_use_case.dart';
import '../use_case/library/listen_prefetch_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';
import '../use_case/manga/prefetch_manga_use_case.dart';

class PrefetchJobManager
    implements
        PrefetchMangaUseCase,
        PrefetchChapterUseCase,
        ListenPrefetchUseCase {
  final BehaviorSubject<List<JobDrift>> _jobs = BehaviorSubject.seeded([]);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final ValueGetter<SearchChapterUseCase> _searchChapterUseCase;
  final PrefetchJobDao _prefetchJobDao;
  final LogBox _log;

  bool _isFetching = false;

  late final StreamSubscription _streamSubscription;

  PrefetchJobManager({
    required LogBox log,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required ValueGetter<SearchChapterUseCase> searchChapterUseCase,
    required PrefetchJobDao prefetchJobDao,
  })  : _log = log,
        _getMangaUseCase = getMangaUseCase,
        _getChapterUseCase = getChapterUseCase,
        _searchChapterUseCase = searchChapterUseCase,
        _prefetchJobDao = prefetchJobDao {
    _streamSubscription = _jobs.distinct().listen(_onData);
    _jobs.addStream(prefetchJobDao.listen());
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _onData(List<JobDrift> jobs) async {
    final job = jobs.firstOrNull;
    if (job == null || _isFetching) return;

    _isFetching = true;

    switch (job.type) {
      case JobTypeEnum.manga:
        await _fetchManga(job);
      case JobTypeEnum.chapter:
        await _fetchChapter(job);
    }

    _isFetching = false;

    _prefetchJobDao.remove(job.toCompanion(true));
  }

  Future<void> _fetchChapter(JobDrift job) async {
    final result = await _getChapterUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
      chapterId: job.chapterId,
    );

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
    final result = await _getMangaUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
    );

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

      await _fetchAllChapter(job);
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
  }

  Future<void> _fetchAllChapter(
    JobDrift job, {
    SearchChapterParameter parameter = const SearchChapterParameter(
      offset: 0,
      page: 1,
      limit: 100,
    ),
  }) async {
    final result = await _searchChapterUseCase().execute(
      source: MangaSourceEnum.fromValue(job.source),
      mangaId: job.mangaId,
      parameter: parameter,
    );

    if (result is Success<Pagination<MangaChapter>>) {
      _log.log(
        'Success fetch manga chapters',
        extra: {
          'manga_id': job.mangaId,
          'chapter_id': job.chapterId,
          'source': job.source,
          'parameter': parameter,
          'data': result.data.toJson((e) => e.toJson()),
        },
        name: runtimeType.toString(),
      );

      for (final chapter in result.data.data ?? <MangaChapter>[]) {
        chapter.id?.let(
          (id) => prefetchChapter(
            mangaId: job.mangaId,
            chapterId: id,
            source: MangaSourceEnum.fromValue(job.source),
          ),
        );
      }

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

    if (result is Error<Pagination<MangaChapter>>) {
      _log.log(
        'Failed fetch manga chapters',
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

  @override
  void prefetchChapter({
    required String mangaId,
    required String chapterId,
    required MangaSourceEnum source,
  }) {
    _prefetchJobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.chapter,
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
      JobTablesCompanion.insert(
        type: JobTypeEnum.manga,
        source: source.value,
        mangaId: mangaId,
      ),
    );
  }

  @override
  Stream<Map<String, Set<String>>> get prefetchedStream {
    final stream = _jobs.map((e) => e.groupListsBy((e) => e.mangaId));
    return stream.map(
      (e) => e.map(
        (key, value) => MapEntry(
          key,
          value.map((e) => e.chapterId).nonNulls.toSet(),
        ),
      ),
    );
  }
}
