import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_screen_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenState> {
  final GetListMangaSourcesUseCase _getAllMangaSourcesUseCase;

  BrowseSourceScreenCubit({
    BrowseSourceScreenState initialState = const BrowseSourceScreenState(
      isLoading: false,
      sources: [],
    ),
    required GetListMangaSourcesUseCase getAllMangaSourcesUseCase,
  })  : _getAllMangaSourcesUseCase = getAllMangaSourcesUseCase,
        super(initialState);

  Future<void> init() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));
    final result = await _getAllMangaSourcesUseCase.execute();
    emit(state.copyWith(isLoading: false));

    if (result is Success<List<MangaSource>>) {
      emit(state.copyWith(sources: result.data));
    }

    if (result is Error<List<MangaSource>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }
}
