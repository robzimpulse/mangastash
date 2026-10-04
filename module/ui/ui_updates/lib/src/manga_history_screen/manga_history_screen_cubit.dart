import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_history_screen_state.dart';

class MangaHistoryScreenCubit extends Cubit<MangaHistoryScreenState>
    with AutoSubscriptionMixin {
  MangaHistoryScreenCubit({
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    MangaHistoryScreenState initialState = const MangaHistoryScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen((e) {
        // Malformed pairs (null manga or chapter) would make the list's
        // itemBuilder return null, which truncates the list at that row
        // (issue #125) — drop them instead.
        final histories = e
            .where((history) => history.manga != null && history.chapter != null)
            .toList();
        emit(state.copyWith(histories: histories));
      }),
    );
  }
}
