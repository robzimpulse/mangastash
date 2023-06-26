import 'package:collection/collection.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'home_cubit_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {

  final SearchRepository searchRepository;
  final AtHomeRepository atHomeRepository;
  final ChapterRepository chapterRepository;

  HomeCubit({
    required this.searchRepository,
    required this.atHomeRepository,
    required this.chapterRepository,
    HomeCubitState initState = const HomeCubitState(),
  }): super(initState);

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));

    emit(state.copyWith(isLoading: false));
  }

}