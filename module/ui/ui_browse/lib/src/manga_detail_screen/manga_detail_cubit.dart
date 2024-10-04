import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState>
    with AutoSubscriptionMixin {
  final GetMangaUseCase _getMangaUseCase;
  final SearchChapterUseCase _getListChapterUseCase;
  final GetMangaSourceUseCase _getMangaSourceUseCase;

  MangaDetailCubit({
    MangaDetailState initialState = const MangaDetailState(),
    required GetMangaUseCase getMangaUseCase,
    required SearchChapterUseCase getListChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required ListenMangaChapterConfig listenMangaChapterConfig,
  })  : _getMangaUseCase = getMangaUseCase,
        _getListChapterUseCase = getListChapterUseCase,
        _getMangaSourceUseCase = getMangaSourceUseCase,
        super(initialState) {
    addSubscription(
      listenMangaChapterConfig.mangaChapterConfigStream
          .listen(_updateMangaConfig),
    );
  }

  void _updateMangaConfig(MangaChapterConfig config) {
    emit(state.copyWith(config: config));
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    await _fetchSource();
    await Future.wait([_fetchManga(), _fetchChapter()]);

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
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _getMangaUseCase.execute(
      mangaId: id,
      source: state.source?.name,
    );

    if (result is Success<Manga>) {
      emit(state.copyWith(manga: result.data));
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(error: () => result.error));
    }
  }

  Future<void> _fetchChapter() async {
    final id = state.mangaId;
    if (id == null || id.isEmpty) return;

    final result = await _getListChapterUseCase.execute(
      mangaId: id,
      source: state.source?.name,
    );

    if (result is Success<List<MangaChapter>>) {
      emit(state.copyWith(chapters: result.data));
    }

    if (result is Error<List<MangaChapter>>) {
      emit(state.copyWith(error: () => result.error));
    }
  }
}
