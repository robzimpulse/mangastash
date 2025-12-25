import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:file/file.dart';
import 'package:flutter/widgets.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/cancel_job_use_case.dart';
import '../use_case/chapter/get_all_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/manga/get_manga_use_case.dart';
import '../use_case/parameter/listen_search_parameter_use_case.dart';
import '../use_case/prefetch/listen_job_use_case.dart';
import '../use_case/prefetch/listen_prefetch_use_case.dart';
import '../use_case/prefetch/prefetch_chapter_use_case.dart';
import '../use_case/prefetch/prefetch_manga_use_case.dart';

class JobManager
    with UserAgentMixin, WidgetsBindingObserver
    implements
        PrefetchMangaUseCase,
        PrefetchChapterUseCase,
        ListenPrefetchUseCase,
        CancelJobUseCase,
        ListenJobUseCase {
  final _jobs = BehaviorSubject<List<JobModel>>.seeded([]);
  final _ongoingJobId = BehaviorSubject<int?>.seeded(null);
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final ValueGetter<GetMangaUseCase> _getMangaUseCase;
  final ValueGetter<GetAllChapterUseCase> _getAllChapterUseCase;
  final ListenSearchParameterUseCase _listenSearchParameterUseCase;
  final ImagesCacheManager _manager;
  final JobDao _jobDao;
  final FileDao _fileDao;
  final LogBox _log;
  final GetRootPathUseCase _getRootPathUseCase;

  late final StreamSubscription _jobStreamSubscription;
  late final StreamSubscription _deleteFileSubscription;

  JobManager({
    required LogBox log,
    required JobDao jobDao,
    required FileDao fileDao,
    required ImagesCacheManager manager,
    required GetRootPathUseCase getRootPathUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required ValueGetter<GetMangaUseCase> getMangaUseCase,
    required ValueGetter<GetAllChapterUseCase> getAllChapterUseCase,
  }) : _log = log,
       _jobDao = jobDao,
       _fileDao = fileDao,
       _manager = manager,
       _getRootPathUseCase = getRootPathUseCase,
       _getMangaUseCase = getMangaUseCase,
       _getChapterUseCase = getChapterUseCase,
       _getAllChapterUseCase = getAllChapterUseCase,
       _listenSearchParameterUseCase = listenSearchParameterUseCase {
    _jobStreamSubscription = _jobs.distinct().listen(_onData);
    /// TODO: @robzimpulse - [_deleteFileSubscription] caused error on unit test
    _deleteFileSubscription = manager.deleteFileEvent.listen(_onDeleteFile);
    _jobs.addStream(jobDao.stream);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _jobStreamSubscription.cancel();
    await _deleteFileSubscription.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _log.log(
        'Resume executing jobs',
        extra: {'state': _jobStreamSubscription.isPaused},
        name: runtimeType.toString(),
      );
      _jobStreamSubscription.resume();
      _deleteFileSubscription.resume();
    }
  }

  void _onDeleteFile((CacheObject object, File file) event) async {
    final (object, file) = event;

    await _jobDao.add(
      JobTablesCompanion.insert(
        imageUrl: Value(object.url),
        path: Value(file.path),
        type: JobTypeEnum.persistentImage,
      ),
    );
  }

  void _onData(List<JobModel> jobs) async {
    final job = jobs.firstOrNull;
    if (job == null || _ongoingJobId.valueOrNull != null) return;

    _ongoingJobId.add(job.id);

    try {
      switch (job.type) {
        case JobTypeEnum.prefetchManga:
          await _fetchManga(job);
        case JobTypeEnum.prefetchChapters:
          await _fetchAllChapter(job);
        case JobTypeEnum.prefetchChapter:
          await _fetchChapter(job);
        case JobTypeEnum.prefetchImage:
          await _fetchImage(job);
        case JobTypeEnum.persistentImage:
          await _persistentImage(job);
      }
    } catch (error, stackTrace) {
      _log.log(
        'Failed execute job ${job.id} - ${job.type}',
        error: error,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
    } finally {
      await _jobDao.remove(job.id);
      _ongoingJobId.add(null);
      _log.log(
        'Success execute job ${job.id} - ${job.type}',
        name: runtimeType.toString(),
      );
    }
  }

  Future<void> _fetchManga(JobModel job) async {
    final mangaId = job.manga?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || source == null) {
      throw Exception('No Manga ID or Source Url');
    }

    final result = await _getMangaUseCase().execute(
      source: source,
      mangaId: mangaId,
      useCache: false,
    );

    if (result is Error<Manga>) {
      throw result.error;
    }
  }

  Future<void> _fetchChapter(JobModel job) async {
    final mangaId = job.manga?.id;
    final chapterId = job.chapter?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || chapterId == null || source == null) {
      throw Exception('No Manga ID or Chapter ID or Source');
    }

    final result = await _getChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      chapterId: chapterId,
      useCache: false,
    );

    if (result is Error<Chapter>) {
      throw result.error;
    }

    if (result is Success<Chapter>) {
      for (final image in result.data.images ?? <String>[]) {
        await _jobDao.add(
          JobTablesCompanion.insert(
            mangaId: Value(mangaId),
            chapterId: Value(chapterId),
            imageUrl: Value(image),
            type: JobTypeEnum.prefetchImage,
          ),
        );
      }
    }
  }

  Future<void> _fetchAllChapter(JobModel job) async {
    final mangaId = job.manga?.id;
    final source = job.manga?.source?.let((e) => SourceEnum.fromValue(name: e));

    if (mangaId == null || source == null) {
      throw Exception('No Manga ID or Source');
    }

    final stream = _listenSearchParameterUseCase.searchParameterState;
    final parameter = stream.valueOrNull?.let(SearchChapterParameter.from);
    await _getAllChapterUseCase().execute(
      source: source,
      mangaId: mangaId,
      parameter: parameter?.copyWith(
        orders: {ChapterOrders.chapter: OrderDirections.ascending},
      ),
      useCache: false,
    );
  }

  Future<void> _fetchImage(JobModel job) async {
    final url = job.image;
    if (url == null) {
      throw Exception('No Image URL');
    }

    await _manager.getSingleFile(url);
  }

  Future<void> _persistentImage(JobModel job) async {
    final url = job.image;
    final path = job.path;
    if (url == null || path == null) {
      throw Exception('No Image URL or Path File');
    }
    final file = _getRootPathUseCase.rootPath.fileSystem.file(path);

    if (!await file.exists()) {
      throw Exception('File on $path do not exists');
    }

    await _fileDao.addFromFile(webUrl: url, file: file);
    await file.delete();
  }

  @override
  void prefetchChapters({required String mangaId, required SourceEnum source}) {
    _jobDao.add(
      JobTablesCompanion.insert(
        type: JobTypeEnum.prefetchChapters,
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
        type: JobTypeEnum.prefetchChapter,
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
        type: JobTypeEnum.prefetchManga,
        source: Value(source.name),
        mangaId: Value(mangaId),
      ),
    );
  }

  @override
  void cancelJob({required int id}) {
    if (_ongoingJobId.valueOrNull == null) {
      _jobDao.remove(id);
      return;
    }

    // TODO: cancel ongoing job
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

  @override
  Stream<int?> get ongoingJobId => _ongoingJobId.stream;
}
