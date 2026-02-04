import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'queue_screen_state.dart';

class QueueScreenCubit extends Cubit<QueueScreenState>
    with AutoSubscriptionMixin {
  QueueScreenCubit({
    required ListenJobUseCase listenJobUseCase,
    QueueScreenState initialState = const QueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenJobUseCase.jobs.listen((jobs) => emit(state.copyWith(jobs: jobs))),
    );
    addSubscription(
      listenJobUseCase.ongoingJobId.listen(
        (id) => emit(state.copyWith(ongoingJobId: id)),
      ),
    );
  }
}
