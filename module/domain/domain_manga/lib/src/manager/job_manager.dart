import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/widgets.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/get_all_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';
import '../use_case/parameter/listen_search_parameter_use_case.dart';
import '../use_case/prefetch/listen_prefetch_use_case.dart';
import '../use_case/prefetch/prefetch_chapter_use_case.dart';
import '../use_case/prefetch/prefetch_manga_use_case.dart';

class JobManager
    with UserAgentMixin, WidgetsBindingObserver
    implements
        PrefetchMangaUseCase,
        PrefetchChapterUseCase,
        ListenPrefetchUseCase {
  final _jobs = BehaviorSubject<List<JobModel>>.seeded([]);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final ValueGetter<GetAllChapterUseCase> _getAllChapterUseCase;
  final ListenSearchParameterUseCase _listenSearchParameterUseCase;
  final StorageManager _storageManager;
  final JobDao _jobDao;
  final LogBox _log;

  bool _isFetching = false;

  late final StreamSubscription _streamSubscription;

  JobManager({
    required LogBox log,
    required JobDao jobDao,
    required StorageManager storageManager,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required ValueGetter<GetAllChapterUseCase> getAllChapterUseCase,
  }) : _log = log,
       _jobDao = jobDao,
       _storageManager = storageManager,
       _getMangaUseCase = getMangaUseCase,
       _getChapterUseCase = getChapterUseCase,
       _getAllChapterUseCase = getAllChapterUseCase,
       _listenSearchParameterUseCase = listenSearchParameterUseCase {
    _streamSubscription = _jobs.distinct().listen(_onData);
    _jobs.addStream(jobDao.stream);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _streamSubscription.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _log.log(
        'Resume executing jobs',
        extra: {'state': _streamSubscription.isPaused},
        name: runtimeType.toString(),
      );
      _streamSubscription.resume();
    }
  }

  void _onData(List<JobModel> jobs) async {
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
    }

    await _jobDao.remove(job.id);
    _isFetching = false;
  }

  Future<void> _fetchManga(JobModel job) async {
    final mangaId = job.manga?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || source == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'error': 'No Manga ID',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final result = await _getMangaUseCase().execute(
      source: source,
      mangaId: mangaId,
      useCache: false,
    );

    if (result is Error<Manga>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
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
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );
    }
  }

  Future<void> _fetchChapter(JobModel job) async {
    final mangaId = job.manga?.id;
    final chapterId = job.chapter?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || chapterId == null || source == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'error': 'No Manga ID or Chapter ID or Source',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final result = await _getChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      chapterId: chapterId,
      useCache: false,
    );

    if (result is Error<Chapter>) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'error': result.error.toString(),
        },
        name: runtimeType.toString(),
      );
    }

    if (result is Success<Chapter>) {
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'data': result.data.toJson(),
        },
        name: runtimeType.toString(),
      );

      for (final image in result.data.images ?? <String>[]) {
        await _jobDao.add(
          JobTablesCompanion.insert(
            mangaId: Value(mangaId),
            chapterId: Value(chapterId),
            imageUrl: Value(image),
            type: JobTypeEnum.image,
          ),
        );
      }
    }
  }

  Future<void> _fetchAllChapter(JobModel job) async {
    final mangaId = job.manga?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || source == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'error': 'No Manga ID or Source',
        },
        name: runtimeType.toString(),
      );
      return;
    }
    final parameter = _listenSearchParameterUseCase.searchParameterState;
    final result = await _getAllChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      parameter: parameter.valueOrNull?.let(
        (value) => SearchChapterParameter.from(
          value,
        ).copyWith(orders: {ChapterOrders.chapter: OrderDirections.ascending}),
      ),
      useCache: false,
    );

    _log.log(
      'Success execute job ${job.id} - ${job.type}',
      extra: {
        'id': job.id,
        'type': job.type,
        'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
        'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
        'image': job.image,
        'data': result.map((e) => e.toJson()),
      },
      name: runtimeType.toString(),
    );
  }

  Future<void> _fetchImage(JobModel job) async {
    final url = job.image;
    if (url == null) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        extra: {
          'id': job.id,
          'type': job.type,
          'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
          'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
          'image': job.image,
          'error': 'No Image URL',
        },
        name: runtimeType.toString(),
      );
      return;
    }

    final file = await _storageManager.images.getSingleFile(url);

    _log.log(
      'Success execute job ${job.id} - ${job.type}',
      extra: {
        'id': job.id,
        'type': job.type,
        'manga': job.manga?.let((e) => Manga.fromDrift(e).toJson()),
        'chapter': job.chapter?.let((e) => Chapter.fromDrift(e).toJson()),
        'image': job.image,
        'path': file.path,
      },
      name: runtimeType.toString(),
    );
  }

  @override
  void prefetchChapters({required String mangaId, required SourceEnum source}) {
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
    required SourceEnum source,
  }) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.chapter,
        source: Value(source.name),
        mangaId: Value(mangaId),
        chapterId: Value(chapterId),
      ),
    );
  }

  @override
  void prefetchManga({required String mangaId, required SourceEnum source}) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.manga,
        source: Value(source.name),
        mangaId: Value(mangaId),
      ),
    );
  }

  @override
  Stream<Set<String>> get chapterIdsStream {
    return _jobs.map((data) => {...data.map((e) => e.chapter?.id).nonNulls});
  }

  @override
  Stream<Set<String>> get mangaIdsStream {
    return _jobs.map((data) => {...data.map((e) => e.manga?.id).nonNulls});
  }

  @override
  Stream<List<JobModel>> get jobsStream => _jobs.stream;
}
