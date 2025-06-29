import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;

  final SearchChapterUseCase _searchChapterUseCase;

  final CrawlUrlUseCase _crawlUrlUseCase;

  final UpdateChapterLastReadAtUseCase _updateChapterLastReadAtUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required MangaReaderScreenState initialState,
    required UpdateChapterLastReadAtUseCase updateChapterLastReadAtUseCase,
    required SearchChapterUseCase searchChapterUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
  })  : _getChapterUseCase = getChapterUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        _searchChapterUseCase = searchChapterUseCase,
        _updateChapterLastReadAtUseCase = updateChapterLastReadAtUseCase,
        super(
          initialState.copyWith(
            parameter: listenSearchParameterUseCase
                .searchParameterState.valueOrNull
                ?.let((e) => SearchChapterParameter.from(e)),
          ),
        );

  @override
  Future<void> close() async {
    await state.chapter?.let(
      (chapter) async => await _updateChapterLastReadAtUseCase.execute(
        chapter: chapter,
      ),
    );
    await super.close();
  }

  Future<void> init() async {
    await Future.wait([
      _fetchChapter(),
      _fetchPreviousAndNextChapter(),
    ]);
  }

  Future<void> _fetchPreviousAndNextChapter() async {
    final mangaId = state.mangaId;
    final source = state.source?.name;

    if (mangaId == null || source == null) return;

    final response = await _searchChapterUseCase.execute(
      source: source,
      mangaId: mangaId,
      parameter: state.parameter.copyWith(
        orders: {ChapterOrders.chapter: OrderDirections.ascending},
      ),
    );

    if (response is Success<Pagination<Chapter>>) {
      final offset = response.data.offset ?? 0;
      final page = response.data.page ?? 0;
      final limit = response.data.limit ?? 0;
      final chapters = response.data.data ?? [];
      final hasNextPage = response.data.hasNextPage;

      emit(
        state.copyWith(
          chapterIds: [
            ...state.chapterIds,
            ...chapters.map((e) => e.id).nonNulls,
          ],
        ),
      );

      if (hasNextPage == true && state.nextChapterId == null) {
        emit(
          state.copyWith(
            parameter: state.parameter.copyWith(
              page: page + 1,
              offset: offset + limit,
              limit: limit,
            ),
          ),
        );
        await _fetchPreviousAndNextChapter();
      }
    }
  }

  Future<void> _fetchChapter() async {
    final chapterId = state.chapterId;
    final mangaId = state.mangaId;
    final source = state.source?.name;

    if (chapterId == null || mangaId == null || source == null) {
      emit(
        state.copyWith(
          error: () => Exception('Empty chapter id or manga id or source'),
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final response = await _getChapterUseCase.execute(
      chapterId: chapterId,
      mangaId: mangaId,
      source: source,
    );

    if (response is Success<Chapter>) {
      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<Chapter>) {
      emit(state.copyWith(error: () => response.error));
    }

    emit(state.copyWith(isLoading: false));
  }

  void recrawl({required String url}) async {
    await _crawlUrlUseCase.execute(url: url);
    await _fetchChapter();
  }
}
