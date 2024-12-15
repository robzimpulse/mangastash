import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_screen_state.dart';

class MangaDetailScreenCubit extends Cubit<MangaDetailScreenState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _getListChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final DownloadChapterUseCase _downloadChapterUseCase;
  final DownloadChapterProgressUseCase _downloadChapterProgressUseCase;

  StreamSubscription? _activeSubscriptions;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase getListChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenAuthUseCase listenAuth,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required DownloadChapterUseCase downloadChapterUseCase,
    required DownloadChapterProgressUseCase downloadChapterProgressUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadChapterUseCase = downloadChapterUseCase,
        _downloadChapterProgressUseCase = downloadChapterProgressUseCase,
        super(initialState) {
    addSubscription(
      listenAuth.authStateStream.distinct().listen(_updateAuthState),
    );
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateMangaLibrary),
    );
  }

  @override
  Future<void> close() async {
    _activeSubscriptions?.cancel();
    await super.close();
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void _updateMangaLibrary(List<Manga> library) {
    emit(state.copyWith(libraries: library));
  }

  void updateMangaConfig(MangaChapterConfig config) {
    emit(state.copyWith(config: config));
  }

  Future<void> init() async {
    await _fetchManga();
    await _fetchChapter();
  }

  Future<void> _fetchManga() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    emit(
      state.copyWith(
        isLoadingChapters: true,
        isLoadingManga: true,
        errorManga: () => null,
      ),
    );

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: state.source,
    );

    if (result is Success<Manga>) {
      emit(
        state.copyWith(
          manga: result.data.copyWith(
            source: state.source,
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

    emit(state.copyWith(isLoadingChapters: true, errorChapters: () => null));

    final result = await _getListChapterUseCase.execute(
      mangaId: id,
      source: state.source,
    );

    if (result is Success<List<MangaChapter>>) {
      final Map<String?, double> downloadProgress = {};
      final List<Stream<(String?, int, double)>> streams = [];
      final chapters = result.data;
      for (final chapter in chapters) {
        final key = DownloadChapterKey(manga: state.manga, chapter: chapter);
        streams.add(
          _downloadChapterProgressUseCase
              .downloadChapterProgressStream(key: key)
              .map((event) => (chapter.id, event.$1, event.$2)),
        );
        downloadProgress[chapter.id] =
            _downloadChapterProgressUseCase.downloadChapterProgress(key: key);
      }

      _activeSubscriptions?.cancel();
      _activeSubscriptions = CombineLatestStream(streams, (values) => values)
          .throttleTime(const Duration(seconds: 1), trailing: true)
          .listen(_updateDownloadChapterProgress);

      emit(
        state.copyWith(
          chapters: result.data,
          downloadProgress: downloadProgress,
        ),
      );
    }

    if (result is Error<List<MangaChapter>>) {
      emit(state.copyWith(errorChapters: () => result.error));
    }

    emit(state.copyWith(isLoadingChapters: false));
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
    final key = DownloadChapterKey(manga: state.manga, chapter: chapter);
    await _downloadChapterUseCase.downloadChapter(key: key);
  }

  void _updateDownloadChapterProgress(List<(String?, int, double)> progress) {
    final downloadProgress = Map.of(
      state.downloadProgress ?? <String?, double>{},
    );

    for (final data in progress) {
      final chapterId = data.$1;
      final totalProgress = data.$3;
      downloadProgress.update(
        chapterId,
        (value) => totalProgress,
        ifAbsent: () => 0.0,
      );
    }

    emit(state.copyWith(downloadProgress: downloadProgress));
  }
}
