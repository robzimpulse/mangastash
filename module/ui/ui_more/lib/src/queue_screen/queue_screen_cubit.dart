import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'queue_screen_state.dart';

class QueueScreenCubit extends Cubit<QueueScreenState>
    with AutoSubscriptionMixin {
  QueueScreenCubit({
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
    QueueScreenState initialState = const QueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenDownloadProgressUseCase.active
          .distinct()
          .throttleTime(const Duration(milliseconds: 200))
          .listen((progress) => emit(state.copyWith(progress: progress))),
    );
    addSubscription(
      listenDownloadProgressUseCase.filenames
          .distinct()
          .throttleTime(const Duration(milliseconds: 200))
          .listen((filenames) => emit(state.copyWith(filenames: filenames))),
    );
  }
}
