import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_state.dart';

class BrowseMangaCubit extends Cubit<BrowseMangaState> {
  final GetMangaSourceUseCase _getMangaSourceUseCase;

  BrowseMangaCubit({
    required BrowseMangaState initialState,
    required GetMangaSourceUseCase getMangaSourceUseCase,
  })  : _getMangaSourceUseCase = getMangaSourceUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final id = state.sourceId;
    if (id == null || id.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          error: () => Exception('no source id'),
        ),
      );
      return;
    }

    final result = await _getMangaSourceUseCase.execute(id);

    if (result is Success<MangaSource>) {
      emit(state.copyWith(source: result.data));
    }

    if (result is Error<MangaSource>) {
      emit(state.copyWith(error: () => result.error));
    }

    emit(state.copyWith(isLoading: false));
  }

  Future<void> next() async {}

  void update({MangaShelfItemLayout? layout}) {
    emit(state.copyWith(layout: layout));
  }
}
