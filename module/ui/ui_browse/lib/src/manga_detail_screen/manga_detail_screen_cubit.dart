import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
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

  final List<StreamSubscription> _activeSubscriptions = [];

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
    addSubscription(listenAuth.authStateStream.listen(_updateAuthState));
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .listen(_updateMangaLibrary),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait(_activeSubscriptions.map((e) => e.cancel()));
    _activeSubscriptions.clear();
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

    emit(state.copyWith(isLoadingManga: true, errorManga: () => null));

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
      await Future.wait(_activeSubscriptions.map((e) => e.cancel()));
      _activeSubscriptions.clear();

      final chapters = result.data;
      for (final chapter in chapters) {
        final key = DownloadChapter(manga: state.manga, chapter: chapter);
        _activeSubscriptions.add(
          _downloadChapterProgressUseCase
              .downloadChapterProgressStream(key: key)
              .listen(
                (event) => _updateDownloadChapterProgress(chapter.id, event.$2),
              ),
        );
      }

      emit(state.copyWith(chapters: result.data));
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

  void downloadChapter({required MangaChapter chapter}) async {
    final key = DownloadChapter(manga: state.manga, chapter: chapter);
    _downloadChapterUseCase.downloadChapter(key: key);
  }

  void _updateDownloadChapterProgress(String? chapterId, double progress) {
    final downloadProgress = state.downloadProgress ?? {};
    emit(
      state.copyWith(
        downloadProgress: Map.of(downloadProgress)
          ..update(chapterId, (value) => progress, ifAbsent: () => 0.0),
      ),
    );
  }
}
