import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../manga_chapter_filter.dart';
import 'manga_history_screen_state.dart';

class MangaHistoryScreenCubit extends Cubit<MangaHistoryScreenState>
    with AutoSubscriptionMixin {
  MangaHistoryScreenCubit({
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    MangaHistoryScreenState initialState = const MangaHistoryScreenState(),
  }) : // Initial states go through the same completeness filter as stream
       // emissions — an all-malformed initialState must land empty so the
       // screen shows its Empty Data state, not blank rows (review on #158).
       super(
         initialState.copyWith(
           histories: onlyCompleteMangaChapters(initialState.histories),
         ),
       ) {
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen((e) {
        // Malformed pairs (null manga or chapter) would make the list's
        // itemBuilder return null, which truncates the list at that row
        // (issue #125) — drop them instead.
        emit(state.copyWith(histories: onlyCompleteMangaChapters(e)));
      }),
    );
  }
}
