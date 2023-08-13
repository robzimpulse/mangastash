import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'detail_manga_state.dart';

class DetailMangaCubit extends Cubit<DetailMangaState> {
  final GetAllChapterUseCase getAllChapterUseCase;

  DetailMangaCubit({
    required this.getAllChapterUseCase,
    DetailMangaState initialState = const DetailMangaState(),
  }) : super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final response = await getAllChapterUseCase.execute(
      parameter: state.parameter,
    );

    if (response is Success<List<MangaChapter>>) {
      final chapters = response.data;
      emit(state.copyWith(manga: state.manga?.copyWith(chapters: chapters)));
    }

    if (response is Error<List<MangaChapter>>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
