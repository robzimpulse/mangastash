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
  final DownloadChapterProgressStreamUseCase
      _downloadChapterProgressStreamUseCase;

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
    required DownloadChapterProgressStreamUseCase
        downloadChapterProgressStreamUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadChapterUseCase = downloadChapterUseCase,
        _downloadChapterProgressUseCase = downloadChapterProgressUseCase,
        _downloadChapterProgressStreamUseCase =
            downloadChapterProgressStreamUseCase,
        super(
          initialState.copyWith(
            source: getMangaSourceUseCase.get(initialState.sourceId),
          ),
        ) {
    addSubscription(listenAuth.authStateStream.listen(_updateAuthState));
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .listen(_updateMangaLibrary),
    );
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
    emit(
      state.copyWith(
        isLoading: true,
        error: () => null,
      ),
    );

    await Future.wait([_fetchManga(), _fetchChapter()]);

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchManga() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: state.source?.name,
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
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> _fetchChapter() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _getListChapterUseCase.execute(
      mangaId: id,
      source: state.source?.name,
    );

    if (result is Success<List<MangaChapter>>) {
      final chapters = result.data.map(
        (e) => e.copyWith(
          downloadProgress:
              _downloadChapterProgressUseCase.downloadChapterProgress(
            source: state.source?.name,
            mangaId: state.mangaId,
            chapterId: e.id,
          ),
        ),
      );

      emit(state.copyWith(chapters: chapters.toList()));
    }

    if (result is Error<List<MangaChapter>>) {
      emit(state.copyWith(error: () => result.error));
    }
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

  void downloadChapter({required String? chapterId}) async {
    _updateDownloadChapterProgress(chapterId, 0.005);

    _downloadChapterUseCase.downloadChapter(
      source: state.source?.name,
      mangaId: state.mangaId,
      chapterId: chapterId,
    );

    final stream =
        _downloadChapterProgressStreamUseCase.downloadChapterProgressStream(
      source: state.source?.name,
      mangaId: state.mangaId,
      chapterId: chapterId,
    );

    addSubscription(
      stream.listen(
        (event) => _updateDownloadChapterProgress(chapterId, event.$2),
      ),
    );
  }

  void _updateDownloadChapterProgress(String? chapterId, double progress) {
    emit(
      state.copyWith(
        chapters: state.chapters
            ?.map(
              (e) => e.id == chapterId
                  ? e.copyWith(downloadProgress: progress)
                  : e,
            )
            .toList(),
      ),
    );
  }
}
