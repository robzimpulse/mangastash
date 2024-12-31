import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  DownloadQueueScreenCubit({
    required ListenActiveDownloadUseCase listenActiveDownloadUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenActiveDownloadUseCase.activeDownloadStream
          .distinct()
          .throttleTime(const Duration(seconds: 1))
          .listen(_updateProgress),
    );
  }

  void _updateProgress(
    Map<DownloadChapterKey, DownloadChapterProgress> progress,
  ) {
    emit(state.copyWith(progress: progress));
  }
}
