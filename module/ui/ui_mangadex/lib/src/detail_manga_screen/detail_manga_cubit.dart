import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'detail_manga_state.dart';

class DetailMangaCubit extends Cubit<DetailMangaState> {

  final GetMangaUseCase getMangaUseCase;

  DetailMangaCubit({
    required Manga manga,
    required this.getMangaUseCase,
    DetailMangaState initialState = const DetailMangaState(),
  }) : super(initialState.copyWith(manga: manga));

  // TODO: implement this
  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final id = state.manga?.id;

    if (id == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: () => 'Manga id Empty',
        ),
      );
      return;
    }

    final result = await getMangaUseCase.execute(id);

    if (result is Success<MangaResponse>) {
      emit(state.copyWith(data: result.data.data));
    }

    if (result is Error<MangaResponse>) {
      emit(state.copyWith(errorMessage: () => result.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }

}
