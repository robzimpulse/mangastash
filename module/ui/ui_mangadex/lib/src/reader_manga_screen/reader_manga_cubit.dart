import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'reader_manga_state.dart';

class ReaderMangaCubit extends Cubit<ReaderMangaState> {
  final GetChapterImageUseCase getChapterImageUseCase;

  ReaderMangaCubit({
    required this.getChapterImageUseCase,
    ReaderMangaState initialState = const ReaderMangaState(),
  }) : super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final response = await getChapterImageUseCase.execute(
      chapterId: state.chapter?.id ?? '',
    );

    if (response is Success<AtHomeResponse>) {
      emit(
        state.copyWith(
          chapter: state.chapter?.copyWith(
            images: response.data.images,
            imagesDataSaver: response.data.imagesDataSaver,
          ),
        ),
      );
    }

    if (response is Error<AtHomeResponse>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
