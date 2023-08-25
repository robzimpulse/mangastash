import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'reader_manga_state.dart';

class ReaderMangaCubit extends Cubit<ReaderMangaState> {
  final GetChapterImageUseCase getChapterImageUseCase;
  final GetChapterUseCase getChapterUseCase;

  ReaderMangaCubit({
    required this.getChapterUseCase,
    required this.getChapterImageUseCase,
    ReaderMangaState initialState = const ReaderMangaState(),
  }) : super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final response = await getChapterUseCase.execute(
      chapterId: state.chapterId ?? '',
    );

    if (response is Success<MangaChapter>) {
      final result = await getChapterImageUseCase.execute(
        chapterId: state.chapterId ?? '',
      );

      if (result is Success<AtHomeResponse>) {
        emit(
          state.copyWith(
            chapter: response.data.copyWith(
              images: result.data.images,
              imagesDataSaver: result.data.imagesDataSaver,
            ),
          ),
        );
      }

      if (result is Error<AtHomeResponse>) {
        emit(state.copyWith(errorMessage: () => result.error.toString()));
      }
    }

    if (response is Error<MangaChapter>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
