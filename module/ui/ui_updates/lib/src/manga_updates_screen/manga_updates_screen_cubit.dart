import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_updates_screen_state.dart';

class MangaUpdatesScreenCubit extends Cubit<MangaUpdatesScreenState>
    with AutoSubscriptionMixin, SortChaptersMixin {
  final PrefetchChapterUseCase _prefetchChapterUseCase;

  MangaUpdatesScreenCubit({
    MangaUpdatesScreenState initialState = const MangaUpdatesScreenState(),
    required ListenUnreadHistoryUseCase listenUnreadHistoryUseCase,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
  }) : _prefetchChapterUseCase = prefetchChapterUseCase,
       super(initialState) {
    addSubscription(
      CombineLatestStream.combine2(
        listenUnreadHistoryUseCase.unreadHistoryStream.distinct(),
        listenMangaFromLibraryUseCase.libraryStateStream.distinct(),
        (histories, libraries) => [
          ...histories.where(
            (e) => [
              libraries.map((e) => e.id).contains(e.manga?.id),
              e.chapter?.readableAt?.let(
                (d) => DateTime.now().difference(d) < const Duration(days: 7),
              ),
            ].nonNulls.every((e) => e),
          ),
        ],
      ).listen(_onUpdate),
    );

    addSubscription(
      listenPrefetchUseCase.chapterIdsStream.distinct().listen(
        _updatePrefetchChapterState,
      ),
    );

    addSubscription(
      listenPrefetchUseCase.mangaIdsStream.distinct().listen(
        _updatePrefetchMangaState,
      ),
    );
  }

  void _onUpdate(List<MangaChapter> histories) {
    final group = histories.groupListsBy((e) => e.manga);
    emit(
      state.copyWith(
        updates: {
          for (final key in group.keys.nonNulls)
            key: sortChapters(
              chapters: [...?group[key]?.map((e) => e.chapter).nonNulls],
              parameter: const SearchChapterParameter(
                orders: {ChapterOrders.chapter: OrderDirections.descending},
              ),
            ),
        },
      ),
    );
  }

  void _updatePrefetchChapterState(Set<String> prefetchedChapterIds) {
    emit(state.copyWith(prefetchedChapterIds: prefetchedChapterIds));
  }

  void _updatePrefetchMangaState(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  Future<void> prefetch() async {
    for (final entry in state.updates.entries) {
      for (final chapter in entry.value) {
        final mangaId = entry.key.id;
        final chapterId = chapter.id;
        final source = entry.key.source.let(SourceEnum.fromName);
        if (mangaId == null || source == null || chapterId == null) continue;
        _prefetchChapterUseCase.prefetchChapter(
          mangaId: mangaId,
          source: source,
          chapterId: chapterId,
        );
      }
    }
  }
}
