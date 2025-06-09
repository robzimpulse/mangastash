import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_screen_state.dart';

class BrowseSourceScreenCubit extends Cubit<BrowseSourceScreenState>
    with AutoSubscriptionMixin {
  BrowseSourceScreenCubit({
    BrowseSourceScreenState initialState = const BrowseSourceScreenState(),
  }) : super(initialState.copyWith(sources: Source.values));
}
