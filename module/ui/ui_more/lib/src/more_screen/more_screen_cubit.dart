import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
    required ListenPrefetchUseCase listenPrefetchUseCase,
  }) : super(initialState) {
    addSubscription(
      listenDownloadProgressUseCase.active
          .distinct()
          .listen(_updateTotalActiveDownload),
    );
    addSubscription(
      listenPrefetchUseCase.jobsStream.distinct().listen(_updateTotalActiveJob),
    );
  }

  void _updateTotalActiveDownload(
    Map<DownloadChapterKey, DownloadChapterProgress> values,
  ) {
    emit(state.copyWith(totalActiveDownload: values.length));
  }

  void _updateTotalActiveJob(List<JobModel> jobs) {
    emit(state.copyWith(totalActiveJob: jobs.length));
  }
}
