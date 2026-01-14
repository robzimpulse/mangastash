import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_history_screen_state.dart';

class MangaHistoryScreenCubit extends Cubit<MangaHistoryScreenState>
    with AutoSubscriptionMixin {
  MangaHistoryScreenCubit({
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    MangaHistoryScreenState initialState = const MangaHistoryScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen(_onUpdate),
    );
  }

  void _onUpdate(List<History> histories) {
    emit(state.copyWith(histories: histories));
  }
}
