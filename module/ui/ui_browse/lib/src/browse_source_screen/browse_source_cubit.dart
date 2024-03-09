import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_state.dart';

class BrowseSourceCubit extends Cubit<BrowseSourceState> {
  final GetAllMangaSourcesUseCase _getAllMangaSourcesUseCase;

  BrowseSourceCubit({
    BrowseSourceState initialState = const BrowseSourceState(
      isLoading: true,
      sources: [],
    ),
    required GetAllMangaSourcesUseCase getAllMangaSourcesUseCase,
  })  : _getAllMangaSourcesUseCase = getAllMangaSourcesUseCase,
        super(initialState);

  void init() async {
    emit(state.copyWith(isLoading: true));
    final result = await _getAllMangaSourcesUseCase.execute();
    await Future.delayed(const Duration(seconds: 5));
    emit(state.copyWith(isLoading: false));

    if (result is Success<List<MangaSource>>) {
      emit(state.copyWith(sources: result.data));
    }

    if (result is Error<List<MangaSource>>) {
      emit(state.copyWith(error: result.error));
    }
  }
}
