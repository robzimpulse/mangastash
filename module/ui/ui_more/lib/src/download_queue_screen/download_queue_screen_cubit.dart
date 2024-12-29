import 'dart:async';

import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_queue_screen_state.dart';

class DownloadQueueScreenCubit extends Cubit<DownloadQueueScreenState>
    with AutoSubscriptionMixin {

  final List<StreamSubscription> _activeSubscription = [];

  DownloadQueueScreenCubit({
    required ListenActiveDownloadUseCase listenActiveDownloadUseCase,
    required ListenProgressDownloadUseCase listenProgressDownloadUseCase,
    DownloadQueueScreenState initialState = const DownloadQueueScreenState(),
  }) : super(initialState) {
    addSubscription(
      listenActiveDownloadUseCase.activeDownloadStream
          .distinct()
          .listen(_updateActiveDownload),
    );
  }

  Future<void> _clearActiveSubscription() async {
    await Future.wait(_activeSubscription.map((e) => e.cancel()));
    _activeSubscription.clear();
  }

  void _updateActiveDownload(Set<DownloadChapterKey> values) {
    final Map<DownloadChapterKey, DownloadChapterProgress> progress = {};
    _clearActiveSubscription();
    for (final value in values) {
      progress[value] = DownloadChapterProgress.zero();
    }
    emit(state.copyWith(progress: progress));
  }

  @override
  Future<void> close() async {
    await _clearActiveSubscription();
    return super.close();
  }
}
