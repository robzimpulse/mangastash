import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;

  final GetAllChapterUseCase _getAllChapterUseCase;

  final CrawlUrlUseCase _crawlUrlUseCase;

  final UpdateChapterLastReadAtUseCase _updateChapterLastReadAtUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required MangaReaderScreenState initialState,
    required UpdateChapterLastReadAtUseCase updateChapterLastReadAtUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required GetAllChapterUseCase getAllChapterUseCase,
  })  : _getChapterUseCase = getChapterUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        _getAllChapterUseCase = getAllChapterUseCase,
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
    final source = state.source;

    if (mangaId == null || source == null) return;

    final response = await _getAllChapterUseCase.execute(
      source: source,
      mangaId: mangaId,
      parameter: state.parameter.copyWith(
        orders: {ChapterOrders.chapter: OrderDirections.ascending},
      ),
    );

    emit(
      state.copyWith(
        chapterIds: [...response.map((e) => e.id).nonNulls],
      ),
    );
  }

  Future<void> _fetchChapter({bool useCache = true}) async {
    final chapterId = state.chapterId;
    final mangaId = state.mangaId;
    final source = state.source;

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
      useCache: useCache,
    );

    if (response is Success<Chapter>) {
      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<Chapter>) {
      emit(state.copyWith(error: () => response.error));
    }

    emit(state.copyWith(isLoading: false));
  }

  void recrawl({required BuildContext context, required String url}) async {
    await _crawlUrlUseCase.execute(context: context, url: url);
    await _fetchChapter(useCache: false);
  }
}
