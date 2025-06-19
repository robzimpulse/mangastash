import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;

  final CrawlUrlUseCase _crawlUrlUseCase;

  final UpdateChapterLastReadAtUseCase _updateChapterLastReadAtUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required MangaReaderScreenState initialState,
    required UpdateChapterLastReadAtUseCase updateChapterLastReadAtUseCase,
  })  : _getChapterUseCase = getChapterUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        _updateChapterLastReadAtUseCase = updateChapterLastReadAtUseCase,
        super(initialState);

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
      _fetchPreviousChapter(),
      _fetchNextChapter(),
    ]);
  }

  Future<void> _fetchPreviousChapter() async {
    // TODO: implement get previous chapter id
  }

  Future<void> _fetchNextChapter() async {
    // TODO: implement get next chapter id
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
    await init();
  }
}
