import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'queue_screen_state.dart';

class QueueScreenCubit extends Cubit<QueueScreenState>
    with AutoSubscriptionMixin {
  QueueScreenCubit({
    required ListenPrefetchUseCase listenPrefetchUseCase,
    QueueScreenState initialState = const QueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenPrefetchUseCase.jobsStream
          .distinct()
          .listen((jobs) => emit(state.copyWith(jobs: jobs))),
    );
  }
}
