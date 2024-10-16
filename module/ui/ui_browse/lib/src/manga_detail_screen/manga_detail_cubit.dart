import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _getListChapterUseCase;
  final GetMangaSourceUseCase _getMangaSourceUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;

  MangaDetailCubit({
    MangaDetailState initialState = const MangaDetailState(),
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase getListChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenAuthUseCase listenAuth,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _getMangaSourceUseCase = getMangaSourceUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        super(initialState) {
    addSubscription(listenAuth.authStateStream.listen(_updateAuthState));
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void updateMangaConfig(MangaChapterConfig config) {
    emit(state.copyWith(config: config));
    _processChapter();
  }

  Future<void> init() async {
    emit(state.copyWith(
      isLoading: true,
      error: () => null,
    ));

    await _fetchSource();
    await Future.wait([_fetchManga(), _fetchChapter()]);

    emit(state.copyWith(isLoading: false));
  }

  void _processChapter() {
    final sortOrder = state.config?.sortOrder;
    final sortOption = state.config?.sortOption;
    List<MangaChapter>? sortedChapter = state.chapters;

    if (sortOrder != null && sortOption != null) {
      switch (sortOption) {
        case MangaChapterSortOptionEnum.chapterNumber:
          switch (sortOrder) {
            case MangaChapterSortOrderEnum.asc:
              sortedChapter = state.chapters?.sorted(
                (a, b) {
                  final aChapter = int.tryParse(a.chapter ?? '');
                  final bChapter = int.tryParse(b.chapter ?? '');
                  if (aChapter == null || bChapter == null) return 0;
                  return -aChapter.compareTo(bChapter);
                },
              );
              break;
            case MangaChapterSortOrderEnum.desc:
              sortedChapter = state.chapters?.sorted(
                (a, b) {
                  final aChapter = int.tryParse(a.chapter ?? '');
                  final bChapter = int.tryParse(b.chapter ?? '');
                  if (aChapter == null || bChapter == null) return 0;
                  return aChapter.compareTo(bChapter);
                },
              );
              break;
          }

          break;
        case MangaChapterSortOptionEnum.uploadDate:
          switch (sortOrder) {
            case MangaChapterSortOrderEnum.asc:
              sortedChapter = state.chapters?.sorted(
                (a, b) {
                  final aDate = a.readableAt?.asDateTime;
                  final bDate = b.readableAt?.asDateTime;
                  if (aDate == null || bDate == null) return 0;
                  return aDate.compareTo(bDate);
                },
              );
              break;
            case MangaChapterSortOrderEnum.desc:
              sortedChapter = state.chapters?.sorted(
                (a, b) {
                  final aDate = a.readableAt?.asDateTime;
                  final bDate = b.readableAt?.asDateTime;
                  if (aDate == null || bDate == null) return 0;
                  return -aDate.compareTo(bDate);
                },
              );
              break;
          }
          break;
      }
    }

    emit(state.copyWith(processedChapters: sortedChapter));
  }

  Future<void> _fetchSource() async {
    final id = state.sourceId;
    if (id == null || id.isEmpty) return;

    final result = await _getMangaSourceUseCase.execute(id);

    if (result is Success<MangaSource>) {
      emit(state.copyWith(source: result.data));
    }

    if (result is Error<MangaSource>) {
      emit(state.copyWith(error: () => result.error));
    }
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

    _processChapter();
  }

  Future<void> addToLibrary({User? user}) async {
    final manga = state.manga;
    final userId = user?.uid ?? state.authState?.user?.uid;
    if (manga == null || userId == null) return;

    if (state.manga?.isOnLibrary != true) {
      final result = await _addToLibraryUseCase.execute(
        manga: manga,
        userId: userId,
      );

      if (result is Success<bool>) {
        emit(
          state.copyWith(
            error: () => null,
            manga: state.manga?.copyWith(
              isOnLibrary: result.data,
            ),
          ),
        );
      }
    } else {
      final result = await _removeFromLibraryUseCase.execute(
        manga: manga,
        userId: userId,
      );
      if (result is Success<bool>) {
        emit(
          state.copyWith(
            error: () => null,
            manga: state.manga?.copyWith(
              isOnLibrary: false,
            ),
          ),
        );
      }
    }
  }
}
