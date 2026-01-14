import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final RecrawlUseCase _recrawlUseCase;
  final GetChapterUseCase _getChapterUseCase;
  final UpdateChapterUseCase _updateChapterUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final GetNeighbourChapterUseCase _getNeighbourChapterUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required MangaReaderScreenState initialState,
    required UpdateChapterUseCase updateChapterUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
    required RecrawlUseCase recrawlUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required GetNeighbourChapterUseCase getNeighbourChapterUseCase,
  }) : _getChapterUseCase = getChapterUseCase,
       _updateChapterUseCase = updateChapterUseCase,
       _recrawlUseCase = recrawlUseCase,
       _prefetchChapterUseCase = prefetchChapterUseCase,
       _getNeighbourChapterUseCase = getNeighbourChapterUseCase,
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
    final chapterId = state.chapterId;
    if (chapterId != null) {
      await _updateChapterUseCase.updateLastRead(chapterId: chapterId);
    }
    await super.close();
  }

  Future<void> init({bool useCache = true}) async {
    emit(state.copyWith(error: () => null));
    await Future.wait([
      _fetchChapter(useCache: useCache),
      _fetchPreviousAndNextChapter(),
    ]);
  }

  Future<void> _fetchPreviousAndNextChapter() async {
    final chapterId = state.chapterId;
    if (chapterId == null) return;

    emit(state.copyWith(isLoadingNeighbourChapters: true));

    final next = await _getNeighbourChapterUseCase.execute(
      chapterId: chapterId,
      direction: NextChapterDirection.next,
    );
    final previous = await _getNeighbourChapterUseCase.execute(
      chapterId: chapterId,
      direction: NextChapterDirection.previous,
    );

    emit(
      state.copyWith(
        previousChapterId: previous.firstOrNull?.id,
        nextChapterId: next.firstOrNull?.id,
        isLoadingNeighbourChapters: false,
      ),
    );

    for (final chapter in [...previous, ...next]) {
      final chapterId = chapter.id;
      final mangaId = state.mangaId;
      final source = state.source;
      if (chapterId == null || mangaId == null || source == null) continue;
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

  Future<void> removeImage({required String url}) async {
    final chapterId = state.chapterId;
    if (chapterId == null) return;
    await _updateChapterUseCase.removeImage(
      chapterId: chapterId,
      imageUrls: [url],
    );
    await init();
  }
}
