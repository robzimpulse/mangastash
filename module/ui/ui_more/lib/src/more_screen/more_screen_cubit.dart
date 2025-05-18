import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenDownloadProgressUseCase listenDownloadProgressUseCase,
  }) : super(initialState) {
    addSubscription(
      listenDownloadProgressUseCase.active
          .distinct()
          .listen(_updateTotalActiveDownload),
    );
  }

  void _updateTotalActiveDownload(
    Map<DownloadChapterKey, DownloadChapterProgress> values,
  ) {
    emit(state.copyWith(totalActiveDownload: values.length));
  }
}
