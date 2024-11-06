import 'dart:async';

import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {
  final DownloadChapterProgressUseCase _downloadChapterProgressUseCase;

  StreamSubscription? _activeSubscription;

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
    final Map<DownloadChapter, (int, double)> progress = {};
    final List<Stream<(DownloadChapter, int, double)>> streams = [];
    for (final value in values) {
      progress[value] = (0, 0.0);
      streams.add(
        _downloadChapterProgressUseCase
            .downloadChapterProgressStream(key: value)
            .map((event) => (value, event.$1, event.$2)),
      );
    }
    emit(state.copyWith(progress: progress));

    _activeSubscription?.cancel();
    _activeSubscription = CombineLatestStream(streams, (values) => values)
        .throttleTime(const Duration(seconds: 1), trailing: true)
        .listen(_updateProgress);
  }

  void _updateProgress(List<(DownloadChapter key, int, double)> values) {
    final progress = Map.of(
      state.progress ?? <DownloadChapter, (int, double)>{},
    );
    for (final (key, downloaded, data) in values) {
      progress.update(key, (value) => (downloaded, data));
    }
    emit(state.copyWith(progress: progress));
  }

  @override
  Future<void> close() {
    _activeSubscription?.cancel();
    return super.close();
  }
}
