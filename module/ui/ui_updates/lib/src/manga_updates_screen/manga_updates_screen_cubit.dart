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
          ...histories
              .where(
                (e) => [
                  libraries.map((e) => e.id).contains(e.manga?.id),
                  e.chapter?.readableAt?.let((d) {
                    final maxAge = const Duration(days: 7);
                    return DateTime.now().difference(d) < maxAge;
                  }),
                ].nonNulls.every((e) => e),
              )
              .sortedBy((e) => e.chapter?.createdAt ?? DateTime.timestamp()),
        ],
      ).listen((e) => emit(state.copyWith(updates: e))),
    );

    addSubscription(
      listenPrefetchUseCase.chapterIdsStream.distinct().listen(
        (e) => emit(state.copyWith(prefetchedChapterIds: e)),
      ),
    );

    addSubscription(
      listenPrefetchUseCase.mangaIdsStream.distinct().listen(
        (e) => emit(state.copyWith(prefetchedMangaIds: e)),
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
