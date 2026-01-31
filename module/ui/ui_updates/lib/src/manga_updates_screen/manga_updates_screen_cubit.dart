import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

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
       super(initialState) {
    addSubscription(
      listenUnreadHistoryUseCase.unreadHistoryStream.distinct().listen(
        (e) => emit(state.copyWith(updates: e)),
      ),
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
      final source = update.manga?.source.let(SourceEnum.fromName);
      if (mangaId == null || source == null || chapterId == null) continue;
      _prefetchChapterUseCase.prefetchChapter(
        mangaId: mangaId,
        source: source,
        chapterId: chapterId,
      );
    }
  }
}
