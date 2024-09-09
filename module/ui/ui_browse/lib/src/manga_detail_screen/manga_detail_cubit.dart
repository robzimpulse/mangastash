import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  final GetMangaUseCase _getMangaUseCase;

  MangaDetailCubit({
    MangaDetailState initialState = const MangaDetailState(),
    required GetMangaUseCase getMangaUseCase,
  })  : _getMangaUseCase = getMangaUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    await _fetchManga();

    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchManga() async {
    final id = state.mangaId;

    if (id == null) return;

    final result = await _getMangaUseCase.execute(mangaId: id);

    if (result is Success<Manga>) {
      emit(state.copyWith(manga: result.data));
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(error: () => result.error));
    }
  }
}
