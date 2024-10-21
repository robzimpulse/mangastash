import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_screen_state.dart';

class BrowseMangaScreenCubit extends Cubit<BrowseMangaScreenState> {
  final GetMangaSourceUseCase _getMangaSourceUseCase;
  final SearchMangaUseCase _searchMangaUseCase;

  BrowseMangaScreenCubit({
    required BrowseMangaScreenState initialState,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required SearchMangaUseCase searchMangaUseCase,
  })  : _getMangaSourceUseCase = getMangaSourceUseCase,
        _searchMangaUseCase = searchMangaUseCase,
        super(initialState);

  Future<void> init({String? title}) async {
    emit(
      state.copyWith(
        isLoading: true,
        mangas: [],
        parameter: state.parameter.copyWith(
          title: title,
          offset: '0',
        ),
      ),
    );
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
    final result = await _searchMangaUseCase.execute(
      source: state.source?.name,
      parameter: state.parameter,
    );

    if (result is Success<Pagination<Manga>>) {
      final offset = int.tryParse(result.data.offset ?? '') ?? 0;
      final limit = result.data.limit ?? 0;
      final total = result.data.total ?? 0;
      final mangas = result.data.data ?? [];

      emit(
        state.copyWith(
          mangas: [...state.mangas, ...mangas].distinct(),
          hasNextPage: [...state.mangas, ...mangas].distinct().length < total,
          parameter: state.parameter.copyWith(
            offset: (offset + limit).toString(),
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

  void update({
    MangaShelfItemLayout? layout,
    bool? isSearchActive,
  }) {
    emit(
      state.copyWith(
        layout: layout,
        isSearchActive: isSearchActive,
      ),
    );
  }
}
