import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenJobUseCase listenJobUseCase,
  }) : super(initialState) {
    addSubscription(
      listenJobUseCase.jobLength.distinct().listen(
        (count) => emit(state.copyWith(jobCount: count)),
      ),
    );
  }
}
