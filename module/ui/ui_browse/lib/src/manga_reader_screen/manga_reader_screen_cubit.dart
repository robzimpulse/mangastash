import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;
  final GetAllChapterUseCase _getAllChapterUseCase;
  final UpdateChapterLastReadAtUseCase _updateChapterLastReadAtUseCase;
  final RecrawlUseCase _recrawlUseCase;
  final ListenPrefetchChapterConfig _listenPrefetchChapterConfig;
  final PrefetchChapterUseCase _prefetchChapterUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required MangaReaderScreenState initialState,
    required UpdateChapterLastReadAtUseCase updateChapterLastReadAtUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required GetAllChapterUseCase getAllChapterUseCase,
    required RecrawlUseCase recrawlUseCase,
    required ListenPrefetchChapterConfig listenPrefetchChapterConfig,
    required PrefetchChapterUseCase prefetchChapterUseCase,
  }) : _getChapterUseCase = getChapterUseCase,
       _getAllChapterUseCase = getAllChapterUseCase,
       _updateChapterLastReadAtUseCase = updateChapterLastReadAtUseCase,
       _recrawlUseCase = recrawlUseCase,
       _listenPrefetchChapterConfig = listenPrefetchChapterConfig,
       _prefetchChapterUseCase = prefetchChapterUseCase,
       super(
         initialState.copyWith(
           parameter: listenSearchParameterUseCase
               .searchParameterState
               .valueOrNull
               ?.let((e) => SearchChapterParameter.from(e)),
         ),
       );

  @override
  Future<void> close() async {
    final chapter = state.chapter;
    if (chapter != null) {
      await _updateChapterLastReadAtUseCase.execute(chapter: chapter);
    }
    await super.close();
  }

  Future<void> init({bool useCache = true}) async {
    emit(state.copyWith(error: () => null));
    await Future.wait([
      _fetchChapter(useCache: useCache),
      _fetchPreviousAndNextChapter(useCache: useCache),
    ]);
  }

  Future<void> _fetchPreviousAndNextChapter({bool useCache = true}) async {
    final mangaId = state.mangaId;
    final source = state.source;

    if (mangaId == null || source == null) return;

    emit(state.copyWith(isLoadingChapterIds: true));

    final response = await _getAllChapterUseCase.execute(
      source: source,
      mangaId: mangaId,
      parameter: state.parameter.copyWith(
        orders: {ChapterOrders.chapter: OrderDirections.ascending},
      ),
      useCache: useCache,
    );

    emit(
      state.copyWith(
        chapterIds: [...response.map((e) => e.id).nonNulls],
        isLoadingChapterIds: false,
      ),
    );

    final prevCount =
        _listenPrefetchChapterConfig.numOfPrefetchedPrevChapter.valueOrNull;
    final nextCount =
        _listenPrefetchChapterConfig.numOfPrefetchedNextChapter.valueOrNull;

    final prevChapters = response
        .splitBefore((e) => e.id == state.chapterId)
        .firstOrNull
        ?.reversed
        .take(prevCount ?? 0);
    final nextChapters = response
        .splitAfter((e) => e.id == state.chapterId)
        .lastOrNull
        ?.take(nextCount ?? 0);

    for (final chapter in [...?prevChapters, ...?nextChapters]) {
      final chapterId = chapter.id;
      if (chapterId == null) continue;
      _prefetchChapterUseCase.prefetchChapter(
        mangaId: mangaId,
        chapterId: chapterId,
        source: source,
      );
    }
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
    await _recrawlUseCase.execute(context: context, url: url);
    await init(useCache: false);
  }
}
