import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_state.dart';

class MangaReaderCubit extends Cubit<MangaReaderState> {
  final GetChapterUseCase _getChapterUseCase;
  final GetMangaSourceUseCase _getMangaSourceUseCase;

  MangaReaderCubit({
    required GetChapterUseCase getChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    MangaReaderState initialState = const MangaReaderState(),
  })  : _getMangaSourceUseCase = getMangaSourceUseCase,
        _getChapterUseCase = getChapterUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    await _fetchSource();
    await _fetchChapter();

    emit(state.copyWith(isLoading: false));
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

  Future<void> _fetchChapter() async {
    final response = await _getChapterUseCase.execute(
      chapterId: state.chapterId,
      source: state.source?.name,
      mangaId: state.mangaId,
    );

    if (response is Success<MangaChapter>) {
      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<MangaChapter>) {
      emit(state.copyWith(error: () => response.error));
    }
  }
}
