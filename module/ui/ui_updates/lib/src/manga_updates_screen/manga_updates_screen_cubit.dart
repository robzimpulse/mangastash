import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_updates_screen_state.dart';

class MangaUpdatesScreenCubit extends Cubit<MangaUpdatesScreenState>
    with AutoSubscriptionMixin, SortChaptersMixin {
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final SourceManager _sourceManager;

  MangaUpdatesScreenCubit({
    MangaUpdatesScreenState initialState = const MangaUpdatesScreenState(),
    required ListenUnreadHistoryUseCase listenUnreadHistoryUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required SourceManager sourceManager,
  }) : _prefetchChapterUseCase = prefetchChapterUseCase,
       _sourceManager = sourceManager,
       super(initialState) {
    addSubscription(
      listenUnreadHistoryUseCase.unreadHistoryStream.distinct().listen(
        (e) {
          final Map<String, SourceExternal?> sources = {...state.sources};
          for (final update in e) {
            final sourceName = update.manga?.source;
            if (sourceName != null && !sources.containsKey(sourceName)) {
              sources[sourceName] = _sourceManager.getSource(sourceName);
            }
          }
          emit(state.copyWith(updates: e, sources: sources));
        },
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
      final source = update.manga?.source.let(_sourceManager.getSource);
      if (mangaId == null || source == null || chapterId == null) continue;
      _prefetchChapterUseCase.prefetchChapter(
        mangaId: mangaId,
        source: source,
        chapterId: chapterId,
      );
    }
  }
}
