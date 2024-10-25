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
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadChapterUseCase = downloadChapterUseCase,
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
      emit(state.copyWith(chapters: result.data));
    }

    if (result is Error<List<MangaChapter>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> addToLibrary({User? user}) async {
    final manga = state.displayManga;
    final userId = user?.uid ?? state.authState?.user?.uid;
    if (manga == null || userId == null) return;

    if (!manga.isOnLibrary) {
      await _addToLibraryUseCase.execute(manga: manga, userId: userId);
    } else {
      await _removeFromLibraryUseCase.execute(manga: manga, userId: userId);
    }
  }

  void downloadChapter({required String? chapterId}) async {
    _updateDownloadChapterProgress(chapterId, 0.0);

    final stream = await _downloadChapterUseCase.downloadChapter(
      source: state.source?.name,
      mangaId: state.mangaId,
      chapterId: chapterId,
    );

    if (stream == null) {
      _updateDownloadChapterProgress(chapterId, 0.0);
      return;
    }

    addSubscription(
      stream.listen(
        (event) => _updateDownloadChapterProgress(chapterId, event),
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
