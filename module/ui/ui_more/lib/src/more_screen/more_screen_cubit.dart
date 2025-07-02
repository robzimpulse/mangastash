import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenPrefetchUseCase listenPrefetchUseCase,
  }) : super(initialState) {
    addSubscription(
      listenPrefetchUseCase.jobsStream
          .distinct()
          .listen((jobs) => emit(state.copyWith(jobCount: jobs.length))),
    );
  }
}
