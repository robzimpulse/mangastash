import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_screen_state.dart';

class MangaDetailScreenCubit extends Cubit<MangaDetailScreenState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _searchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final DownloadChapterUseCase _downloadChapterUseCase;
  final GetMangaSourceUseCase _getMangaSourceUseCase;
  final CrawlUrlUseCase _crawlUrlUseCase;

  StreamSubscription? _activeSubscriptions;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase searchChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenAuthUseCase listenAuth,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required DownloadChapterUseCase downloadChapterUseCase,
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _searchChapterUseCase = searchChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadChapterUseCase = downloadChapterUseCase,
        _getMangaSourceUseCase = getMangaSourceUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        super(initialState) {
    addSubscription(
      listenAuth.authStateStream.distinct().listen(_updateAuthState),
    );
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateMangaLibrary),
    );
    addSubscription(
      listenDownloadProgressUseCase.all.distinct().listen(_updateMangaProgress),
    );
  }

  @override
  Future<void> close() async {
    await _activeSubscriptions?.cancel();
    await super.close();
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void _updateMangaLibrary(List<String> library) {
    emit(state.copyWith(libraries: library));
  }

  void updateMangaConfig(MangaChapterConfig config) {
    emit(state.copyWith(config: config));
  }

  void _updateMangaProgress(
    Map<DownloadChapterKey, DownloadChapterProgress> progress,
  ) {
    emit(state.copyWith(progress: progress));
  }

  Future<void> init({ChapterOrders order = ChapterOrders.chapter}) async {
    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          offset: 0,
          page: 0,
          limit: 20,
          orders: {order: OrderDirections.descending},
        ),
        isLoadingChapters: true,
        errorChapters: () => null,
      ),
    );

    await Future.wait([_fetchSource(), _fetchManga()]);
    await _fetchChapter();
  }

  Future<void> _fetchManga() async {
    final id = state.manga?.id ?? state.mangaId;
    if (id == null || id.isEmpty) return;

    emit(
      state.copyWith(
        isLoadingChapters: true,
        isLoadingManga: state.manga == null,
        errorManga: () => null,
      ),
    );

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: state.sourceEnum,
    );

    if (result is Success<Manga>) {
      emit(
        state.copyWith(
          manga: result.data.copyWith(
            source: state.sourceEnum,
          ),
        ),
      );
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(errorManga: () => result.error));
    }

    emit(state.copyWith(isLoadingManga: false));
  }

  Future<void> _fetchChapter() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _searchChapterUseCase.execute(
      mangaId: id,
      source: state.sourceEnum,
      parameter: state.parameter,
    );

    if (result is Success<Pagination<MangaChapter>>) {
      final offset = result.data.offset ?? 0;
      final page = result.data.page ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final chapters = result.data.data ?? [];
      final hasNextPage = result.data.hasNextPage;

      final allChapters = [...?state.chapters, ...chapters].distinct();

      emit(
        state.copyWith(
          chapters: allChapters,
          hasNextPage: hasNextPage ?? allChapters.length < total,
          parameter: state.parameter.copyWith(
            page: page + 1,
            offset: offset + limit,
            limit: limit,
          ),
          errorChapters: () => null,
        ),
      );
    }

    if (result is Error<Pagination<MangaChapter>>) {
      emit(state.copyWith(errorChapters: () => result.error));
    }

    emit(state.copyWith(isLoadingChapters: false));
  }

  Future<void> _fetchSource() async {
    final sourceEnum = state.sourceEnum;
    if (sourceEnum == null) return;
    emit(state.copyWith(source: _getMangaSourceUseCase.get(sourceEnum)));
  }

  Future<void> next() async {
    if (!state.hasNextPage || state.isPagingNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetchChapter();
    emit(state.copyWith(isPagingNextPage: false));
  }

  Future<void> addToLibrary({User? user}) async {
    final manga = state.manga;
    final userId = user?.uid ?? state.authState?.user?.uid;
    if (manga == null || userId == null) return;

    if (state.isOnLibrary) {
      await _removeFromLibraryUseCase.execute(manga: manga, userId: userId);
    } else {
      await _addToLibraryUseCase.execute(manga: manga, userId: userId);
    }
  }

  Future<void> downloadChapter({required MangaChapter chapter}) async {
    final key = DownloadChapterKey.create(manga: state.manga, chapter: chapter);
    await _downloadChapterUseCase.execute(key: key);
  }

  Future<void> downloadAllChapter() async {
    for (final chapter in state.processedChapters.values) {
      await downloadChapter(chapter: chapter);
    }
  }

  void recrawl() async {
    final url = state.manga?.webUrl;
    if (url == null) return;
    await _crawlUrlUseCase.execute(url: url);
    await _fetchChapter();
  }

  // void _updateDownloadChapterProgress(List<(String?, int, double)> progress) {
  //   final downloadProgress = Map.of(
  //     state.downloadProgress ?? <String?, double>{},
  //   );
  //
  //   for (final data in progress) {
  //     final chapterId = data.$1;
  //     final totalProgress = data.$3;
  //     downloadProgress.update(
  //       chapterId,
  //       (value) => totalProgress,
  //       ifAbsent: () => 0.0,
  //     );
  //   }
  //
  //   emit(state.copyWith(downloadProgress: downloadProgress));
  // }
}
