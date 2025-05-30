import 'dart:async';
import 'dart:ui';

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
  final CrawlUrlUseCase _crawlUrlUseCase;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase searchChapterUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenAuthUseCase listenAuth,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required DownloadChapterUseCase downloadChapterUseCase,
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _searchChapterUseCase = searchChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadChapterUseCase = downloadChapterUseCase,
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
    addSubscription(
      listenLocaleUseCase.localeDataStream.distinct().listen(_updateLocale),
    );
    addSubscription(
      listenPrefetchUseCase.prefetchedStream.distinct().listen(_updatePrefetch),
    );
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void _updateMangaLibrary(List<Manga> library) {
    emit(state.copyWith(libraries: library));
  }

  void _updatePrefetch(Map<String, Set<String>> prefetched) {
    emit(state.copyWith(prefetched: prefetched));
  }

  void updateMangaConfig(MangaChapterConfig config) async {
    emit(state.copyWith(config: config));
    await init();
  }

  void _updateMangaProgress(
    Map<DownloadChapterKey, DownloadChapterProgress> progress,
  ) {
    emit(state.copyWith(progress: progress));
  }

  void _updateLocale(Locale? locale) {
    final codes = Language.fromCode(locale?.languageCode).languageCodes;

    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          translatedLanguage: {
            ...?state.parameter.translatedLanguage,
            ...codes,
          }.toList(),
        ),
      ),
    );
  }

  Future<void> init() async {
    final option = switch (state.config.sortOption) {
      MangaChapterSortOptionEnum.chapterNumber => ChapterOrders.chapter,
      MangaChapterSortOptionEnum.uploadDate => ChapterOrders.readableAt,
    };

    final direction = switch (state.config.sortOrder) {
      MangaChapterSortOrderEnum.asc => OrderDirections.ascending,
      MangaChapterSortOrderEnum.desc => OrderDirections.descending,
    };

    emit(
      state.copyWith(
        parameter: state.parameter.copyWith(
          offset: 0,
          page: 0,
          limit: 20,
          orders: {option: direction},
        ),
        isLoadingManga: true,
        isLoadingChapters: true,
        errorChapters: () => null,
        errorManga: () => null,
      ),
    );

    await _fetchManga();
    await _fetchChapter();
  }

  Future<void> _fetchManga() async {
    final id = state.manga?.id ?? state.mangaId;
    if (id == null || id.isEmpty) return;

    emit(
      state.copyWith(
        isLoadingManga: state.manga == null,
        errorManga: () => null,
      ),
    );

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: state.sourceEnum,
    );

    if (result is Success<Manga>) {
      emit(state.copyWith(manga: result.data));
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(errorManga: () => result.error));
    }

    emit(state.copyWith(isLoadingManga: false));
  }

  Future<void> _fetchChapter() async {
    final id = state.manga?.id ?? state.mangaId;
    if (id == null || id.isEmpty) return;

    emit(
      state.copyWith(
        isLoadingChapters: !(state.chapters?.isNotEmpty == true),
        errorChapters: () => null,
      ),
    );

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
          sourceUrl: () => result.data.sourceUrl,
        ),
      );
    }

    if (result is Error<Pagination<MangaChapter>>) {
      emit(state.copyWith(errorChapters: () => result.error));
    }

    emit(state.copyWith(isLoadingChapters: false));
  }

  Future<void> next() async {
    if (state.isLoadingChapters) return;
    if (!state.hasNextPage || state.isPagingNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetchChapter();
    emit(state.copyWith(isPagingNextPage: false));
  }

  Future<void> addToLibrary() async {
    final manga = state.manga;
    if (manga == null) return;
    if (state.isOnLibrary) {
      await _removeFromLibraryUseCase.execute(manga: manga);
    } else {
      await _addToLibraryUseCase.execute(manga: manga);
    }
  }

  void downloadChapter({required MangaChapter chapter}) {
    final mangaId = state.manga?.id;
    final chapterId = chapter.id;
    final source = state.manga?.source;
    if (mangaId == null || chapterId == null || source == null) return;
    _downloadChapterUseCase.downloadChapter(
      mangaId: mangaId,
      chapterId: chapterId,
      source: source,
    );
  }

  void downloadAllChapter() {
    for (final chapter in state.processedChapters.values) {
      downloadChapter(chapter: chapter);
    }
  }

  void recrawl({required String url}) async {
    await _crawlUrlUseCase.execute(url: url);
    await init();
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
