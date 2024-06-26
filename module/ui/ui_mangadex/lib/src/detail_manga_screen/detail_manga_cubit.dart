import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'detail_manga_state.dart';

class DetailMangaCubit extends Cubit<DetailMangaState> {
  final GetAllChapterUseCase getAllChapterUseCase;
  final GetMangaUseCase getMangaUseCase;

  DetailMangaCubit({
    required this.getAllChapterUseCase,
    required this.getMangaUseCase,
    DetailMangaState initialState = const DetailMangaState(),
  }) : super(initialState);

  Future<void> init() async {
    final mangaId = state.parameter.mangaId;

    if (mangaId == null) {
      emit(state.copyWith(errorMessage: () => 'No Manga ID'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    final response = await getMangaUseCase.execute(
      mangaId,
      includes: state.parameter.includes,
    );

    if (response is Success<MangaDeprecated>) {
      final result = await getAllChapterUseCase.execute(
        parameter: state.parameter,
      );

      if (result is Success<List<MangaChapterDeprecated>>) {
        emit(
          state.copyWith(
            manga: response.data.copyWith(
              chapters: result.data,
            ),
          ),
        );
      }

      if (result is Error<List<MangaChapterDeprecated>>) {
        emit(state.copyWith(errorMessage: () => result.error.toString()));
      }
    }

    if (response is Error<MangaDeprecated>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
