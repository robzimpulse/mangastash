import 'package:domain_manga/domain_manga.dart';
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
    final sources = await _getAllMangaSourcesUseCase.execute();
    emit(state.copyWith(sources: sources, isLoading: false));
  }
}
