import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_screen_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenState>
    with AutoSubscriptionMixin {
  BrowseSourceScreenCubit({
    BrowseSourceScreenState initialState = const BrowseSourceScreenState(),
    required ListenSourcesUseCase listenSourceUseCase,
  }) : super(initialState) {
    addSubscription(
      listenSourceUseCase.sourceStateStream.distinct().listen(_updateSources),
    );
  }

  void _updateSources(List<SourceExternal> sources) {
    emit(state.copyWith(sources: sources));
  }
}
