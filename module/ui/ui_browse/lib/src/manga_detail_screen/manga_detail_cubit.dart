import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  final GetMangaUseCase _getMangaUseCase;
  final GetListChapterUseCase _getListChapterUseCase;

  MangaDetailCubit({
    MangaDetailState initialState = const MangaDetailState(),
    required GetMangaUseCase getMangaUseCase,
    required GetListChapterUseCase getListChapterUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    await _fetchManga();
    await _fetchChapter();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchManga() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _getMangaUseCase.execute(mangaId: id);

    if (result is Success<Manga>) {
      emit(state.copyWith(manga: result.data));
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
      source: state.manga?.source,
    );

    if (result is Success<List<MangaChapter>>) {
      emit(state.copyWith(chapters: result.data));
    }

    if (result is Error<List<MangaChapter>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }
}
