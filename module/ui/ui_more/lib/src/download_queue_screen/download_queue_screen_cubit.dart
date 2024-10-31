import 'dart:async';

import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  final DownloadChapterProgressUseCase _downloadChapterProgressUseCase;

  final List<StreamSubscription> _activeSubscriptions = [];

  DownloadQueueScreenCubit({
    required ListenActiveDownloadUseCase listenActiveDownloadUseCase,
    required DownloadChapterProgressUseCase downloadChapterProgressUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  })  : _downloadChapterProgressUseCase = downloadChapterProgressUseCase,
        super(initialState) {
    addSubscription(
      listenActiveDownloadUseCase.activeDownloadStream
          .listen(_updateActiveDownload),
    );
  }

  void _updateActiveDownload(Set<DownloadChapter> values) {
    emit(
      state.copyWith(
        progress: {for (final value in values) value: (0, 0.0)},
      ),
    );

    _clearActiveSubscription();
    for (final value in values) {
      _addActiveSubscription(
        _downloadChapterProgressUseCase
            .downloadChapterProgressStream(key: value)
            .listen((event) => _updateProgress(value, event)),
      );
    }
  }

  void _updateProgress(DownloadChapter key, (int, double) value) {
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
