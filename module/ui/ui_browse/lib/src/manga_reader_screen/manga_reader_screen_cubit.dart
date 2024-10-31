import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState> {
  final GetChapterUseCase _getChapterUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    MangaReaderScreenState initialState = const MangaReaderScreenState(),
  })  : _getChapterUseCase = getChapterUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    await _fetchChapter();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchChapter() async {
    final response = await _getChapterUseCase.execute(
      chapterId: state.chapterId,
      source: state.source,
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
