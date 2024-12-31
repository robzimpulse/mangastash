import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  DownloadQueueScreenCubit({
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenDownloadProgressUseCase.active
          .distinct()
          .throttleTime(const Duration(milliseconds: 200))
          .listen((progress) => emit(state.copyWith(progress: progress))),
    );
  }
}
