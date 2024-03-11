import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_state.dart';

class BrowseMangaCubit extends Cubit<BrowseMangaState> {
  final GetMangaSourceUseCase _getMangaSourceUseCase;
  final SearchMangaUseCase _searchMangaUseCase;
  final AddOrUpdateMangaUseCase _addOrUpdateMangaUseCase;

  BrowseMangaCubit({
    required BrowseMangaState initialState,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required SearchMangaUseCase searchMangaUseCase,
    required AddOrUpdateMangaUseCase addOrUpdateMangaUseCase,
  })  : _getMangaSourceUseCase = getMangaSourceUseCase,
        _searchMangaUseCase = searchMangaUseCase,
        _addOrUpdateMangaUseCase = addOrUpdateMangaUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await Future.wait([_fetchSource(), _fetchManga()]);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchSource() async {
    final id = state.sourceId;
    if (id == null || id.isEmpty) return;

    final result = await _getMangaSourceUseCase.execute(id);

    if (result is Success<MangaSource>) {
      emit(state.copyWith(source: result.data));
    }

    if (result is Error<MangaSource>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> _fetchManga() async {
    final result = await _searchMangaUseCase.execute();

    if (result is Success<Pagination<Manga>>) {
      emit(state.copyWith(mangas: result.data.data));
      await _addOrUpdateMangaUseCase.execute(data: result.data.data ?? []);
    }

    if (result is Error<Pagination<Manga>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> next() async {}

  void update({MangaShelfItemLayout? layout}) {
    emit(state.copyWith(layout: layout));
  }
}
