import 'package:core_auth/core_auth.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_detail_screen_state.dart';

class MangaDetailScreenCubit extends Cubit<MangaDetailScreenState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _getListChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;
  final GetChapterUseCase _getChapterUseCase;
  final BaseCacheManager _cacheManager;

  MangaDetailScreenCubit({
    required MangaDetailScreenState initialState,
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase getListChapterUseCase,
    required GetChapterUseCase getChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenAuthUseCase listenAuth,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required BaseCacheManager cacheManager,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _getChapterUseCase = getChapterUseCase,
        _cacheManager = cacheManager,
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
    // TODO: perform download chapter
  //   final response = await _getChapterUseCase.execute(
  //     chapterId: chapterId,
  //     source: state.source?.name,
  //     mangaId: state.mangaId,
  //   );
  //
  //   if (response is Success<MangaChapter>) {
  //     final images = response.data.images ?? [];
  //     final combiner = CombineLatestStream(
  //       images.map((e) => _cacheManager.getFileStream(e, withProgress: true)),
  //       (values) {
  //         final progress = values.whereType<DownloadProgress>();
  //         return progress.fold<double>(
  //           0,
  //           (prev, element) => (element.progress ?? 0) / progress.length,
  //         );
  //       },
  //     );
  //
  //     combiner.listen((value) {
  //       print(value);
  //     });
  //   }
  }
}
