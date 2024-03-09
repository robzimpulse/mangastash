import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'reader_manga_state.dart';

class ReaderMangaCubit extends Cubit<ReaderMangaState> {
  final GetChapterUseCase getChapterUseCase;

  ReaderMangaCubit({
    required this.getChapterUseCase,
    ReaderMangaState initialState = const ReaderMangaState(),
  }) : super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final response = await getChapterUseCase.execute(
      chapterId: state.chapterId ?? '',
    );

    if (response is Success<MangaChapterDeprecated>) {
      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<MangaChapterDeprecated>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
