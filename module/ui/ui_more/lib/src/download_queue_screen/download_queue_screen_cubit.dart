import 'dart:async';

import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  final DownloadChapterProgressStreamUseCase
      _downloadChapterProgressStreamUseCase;

  final List<StreamSubscription> _activeSubscriptions = [];

  DownloadQueueScreenCubit({
    required ListenActiveDownloadUseCase listenActiveDownloadUseCase,
    required DownloadChapterProgressStreamUseCase
        downloadChapterProgressStreamUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  })  : _downloadChapterProgressStreamUseCase =
            downloadChapterProgressStreamUseCase,
        super(initialState) {
    addSubscription(
      listenActiveDownloadUseCase.activeDownloadStream
          .listen(_updateActiveDownload),
    );
  }

  void _updateActiveDownload(Set<DownloadChapterKey> values) {
    emit(
      state.copyWith(
        progress: {for (final value in values) value: (0, 0.0)},
      ),
    );

    _clearActiveSubscription();
    for (final value in values) {
      _addActiveSubscription(
        _downloadChapterProgressStreamUseCase
            .downloadChapterProgressStream(
              source: value.$1,
              mangaId: value.$2,
              chapterId: value.$3,
            )
            .listen(
              (event) => _updateProgress(value, event),
            ),
      );
    }
  }

  void _updateProgress(DownloadChapterKey key, (int, double) value) {
    final progress = state.progress ?? {};
    emit(state.copyWith(progress: Map.of(progress)..[key] = value));
  }

  void _clearActiveSubscription() {
    for (var sub in _activeSubscriptions) {
      sub.cancel();
    }
    _activeSubscriptions.clear();
  }

  void _addActiveSubscription(StreamSubscription subscription) {
    _activeSubscriptions.add(subscription);
  }

  @override
  Future<void> close() {
    _clearActiveSubscription();
    return super.close();
  }
}
