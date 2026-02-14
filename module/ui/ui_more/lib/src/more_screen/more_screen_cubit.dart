import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  final UpdateSettingDownloadedOnlyUseCase _updateSettingDownloadedOnlyUseCase;

  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenJobUseCase listenJobUseCase,
    required ListenSettingDownloadedOnlyUseCase
    listenSettingDownloadedOnlyUseCase,
    required UpdateSettingDownloadedOnlyUseCase
    updateSettingDownloadedOnlyUseCase,
  }) : _updateSettingDownloadedOnlyUseCase = updateSettingDownloadedOnlyUseCase,
       super(initialState) {
    addSubscription(
      CombineLatestStream.combine2(
        listenJobUseCase.jobLength,
        listenJobUseCase.upcomingJobLength,
        (a, b) => a + b,
      ).distinct().listen((count) => emit(state.copyWith(jobCount: count))),
    );
    addSubscription(
      listenSettingDownloadedOnlyUseCase.downloadedOnlyState.distinct().listen(
        (value) => emit(state.copyWith(isDownloadedOnly: value)),
      ),
    );
  }

  void toggleIsDownloadedOnly() {
    _updateSettingDownloadedOnlyUseCase.updateDownloadedOnly(
      downloadedOnly: !state.isDownloadedOnly,
    );
  }
}
