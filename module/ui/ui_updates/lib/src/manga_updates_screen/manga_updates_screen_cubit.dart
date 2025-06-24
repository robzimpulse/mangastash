import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_updates_screen_state.dart';

class MangaUpdatesScreenCubit extends Cubit<MangaUpdatesScreenState>
    with AutoSubscriptionMixin, SortChaptersMixin {
  MangaUpdatesScreenCubit({
    required ListenUnreadHistoryUseCase listenUnreadHistoryUseCase,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    MangaUpdatesScreenState initialState = const MangaUpdatesScreenState(),
  }) : super(initialState) {
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
  }

  void _onUpdate(List<History> histories) {
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

  void init() {}
}
