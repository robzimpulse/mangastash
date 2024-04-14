import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_state.dart';

class BrowseMangaCubit extends Cubit<BrowseMangaState> {
  final GetMangaSourceUseCase _getMangaSourceUseCase;
  final SearchMangaOnMangaDexUseCase _searchMangaUseCase;
  final AddOrUpdateMangaUseCase _addOrUpdateMangaUseCase;

  BrowseMangaCubit({
    required BrowseMangaState initialState,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required SearchMangaOnMangaDexUseCase searchMangaUseCase,
    required AddOrUpdateMangaUseCase addOrUpdateMangaUseCase,
  })  : _getMangaSourceUseCase = getMangaSourceUseCase,
        _searchMangaUseCase = searchMangaUseCase,
        _addOrUpdateMangaUseCase = addOrUpdateMangaUseCase,
        super(initialState);

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await _fetchSource();
    await _fetchManga();
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

    // TODO: limit search manga use case based on source manga

    final result = await _searchMangaUseCase.execute(
      parameter: state.parameter,
    );

    if (result is Success<Pagination<Manga>>) {
      final offset = result.data.offset;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final mangas = result.data.data ?? [];

      _addOrUpdateMangaUseCase.execute(
        data: mangas.map((e) => e.copyWith(source: state.source)).toList(),
      );

      emit(
        state.copyWith(
          mangas: [...state.mangas, ...mangas].distinct(),
          hasNextPage: mangas.length < total,
          parameter: state.parameter.copyWith(
            offset: offset,
            limit: limit,
          ),
          error: () => null,
        ),
      );
    }

    if (result is Error<Pagination<Manga>> && state.mangas.isEmpty) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> next() async {
    if (!state.hasNextPage) return;
    emit(state.copyWith(isPagingNextPage: true));
    await _fetchManga();
    emit(state.copyWith(isPagingNextPage: false));
  }

  void update({MangaShelfItemLayout? layout}) {
    emit(state.copyWith(layout: layout));
  }
}
