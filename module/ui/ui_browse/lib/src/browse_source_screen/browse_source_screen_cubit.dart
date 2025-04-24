import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_screen_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenState>
    with AutoSubscriptionMixin {
  BrowseSourceScreenCubit({
    BrowseSourceScreenState initialState = const BrowseSourceScreenState(),
    required ListenMangaSourceUseCase listenMangaSourceUseCase,
  }) : super(initialState) {
    addSubscription(
      listenMangaSourceUseCase.mangaSourceStateStream
          .distinct()
          .listen(_updateSourceState),
    );
  }

  void _updateSourceState(Map<String, MangaSourceFirebase> sources) {
    emit(state.copyWith(sources: sources.values.toList()));
  }
}
