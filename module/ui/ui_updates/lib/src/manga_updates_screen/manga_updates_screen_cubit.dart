import 'package:collection/collection.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_updates_screen_state.dart';

class MangaUpdatesScreenCubit extends Cubit<MangaUpdatesScreenState>
    with AutoSubscriptionMixin {
  MangaUpdatesScreenCubit({
    required ListenUnreadHistoryUseCase listenUnreadHistoryUseCase,
    MangaUpdatesScreenState initialState = const MangaUpdatesScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenUnreadHistoryUseCase.unreadHistoryStream
          .distinct()
          .listen(_onUpdate),
    );
  }

  void _onUpdate(List<History> histories) {
    final group = histories.groupListsBy((e) => e.manga);
    emit(
      state.copyWith(
        updates: {
          for (final key in group.keys.nonNulls)
            key: [...?group[key]?.map((e) => e.chapter).nonNulls],
        },
      ),
    );
  }

  void init() {}
}
