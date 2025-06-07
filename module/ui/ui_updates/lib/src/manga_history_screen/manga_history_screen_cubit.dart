import 'package:collection/collection.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_history_screen_state.dart';

class MangaHistoryScreenCubit extends Cubit<MangaHistoryScreenState>
    with AutoSubscriptionMixin {
  MangaHistoryScreenCubit({
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    required MangaHistoryScreenState initialState,
  }) : super(initialState) {
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen(_onUpdate),
    );
  }

  void _onUpdate(List<History> histories) {

    final group = histories.groupListsBy((e) => e.manga);

    emit(
      state.copyWith(
        histories: {
          for (final key in group.keys.nonNulls)
            key: [...?group[key]?.map((e) => e.chapter).nonNulls],
        },
      ),
    );
  }

  void init() {}
}
