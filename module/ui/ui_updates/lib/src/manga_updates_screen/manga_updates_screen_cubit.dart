import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../manga_chapter_filter.dart';
import 'manga_updates_screen_state.dart';

class MangaUpdatesScreenCubit extends Cubit<MangaUpdatesScreenState>
    with AutoSubscriptionMixin, SortChaptersMixin {
  final PrefetchChapterUseCase _prefetchChapterUseCase;

  MangaUpdatesScreenCubit({
    MangaUpdatesScreenState initialState = const MangaUpdatesScreenState(),
    required ListenUnreadHistoryUseCase listenUnreadHistoryUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
  }) : _prefetchChapterUseCase = prefetchChapterUseCase,
       // Initial states go through the same completeness filter as stream
       // emissions — an all-malformed initialState must land empty so the
       // screen shows its Empty Data state, not blank rows (review on #158).
       super(
         initialState.copyWith(
           updates: onlyCompleteMangaChapters(initialState.updates),
         ),
       ) {
    addSubscription(
      listenUnreadHistoryUseCase.unreadHistoryStream.distinct().listen((e) {
        // Malformed pairs (null manga or chapter) would make the list's
        // itemBuilder return null, which truncates the list at that row
        // (issue #125) — drop them instead.
        emit(state.copyWith(updates: onlyCompleteMangaChapters(e)));
      }),
    );

    addSubscription(
      listenPrefetchUseCase.chapterIdsStream.distinct().listen(
        (e) => emit(state.copyWith(prefetchedChapterIds: e)),
      ),
    );
  }

  void prefetch() {
    for (final update in state.updates) {
      final mangaId = update.manga?.id;
      final chapterId = update.chapter?.id;
      final source = update.manga?.source.let(Sources.fromName);
      if (mangaId == null || source == null || chapterId == null) continue;
      _prefetchChapterUseCase.prefetchChapter(
        mangaId: mangaId,
        source: source,
        chapterId: chapterId,
      );
    }
  }
}
