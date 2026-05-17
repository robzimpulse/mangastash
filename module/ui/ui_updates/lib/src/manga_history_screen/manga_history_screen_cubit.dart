import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_history_screen_state.dart';

class MangaHistoryScreenCubit extends Cubit<MangaHistoryScreenState>
    with AutoSubscriptionMixin {
  final SourceManager _sourceManager;

  MangaHistoryScreenCubit({
    required ListenReadHistoryUseCase listenReadHistoryUseCase,
    required SourceManager sourceManager,
    MangaHistoryScreenState initialState = const MangaHistoryScreenState(),
  }) : _sourceManager = sourceManager,
       super(initialState) {
    addSubscription(
      listenReadHistoryUseCase.readHistoryStream.distinct().listen(
        (e) {
          final Map<String, SourceExternal?> sources = {...state.sources};
          for (final update in e) {
            final sourceName = update.manga?.source;
            if (sourceName != null && !sources.containsKey(sourceName)) {
              sources[sourceName] = _sourceManager.getSource(sourceName);
            }
          }
          emit(state.copyWith(histories: e, sources: sources));
        },
      ),
    );
  }
}
