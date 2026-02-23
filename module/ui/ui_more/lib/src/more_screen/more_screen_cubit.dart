import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  final UpdateSettingDownloadedOnlyUseCase _updateSettingDownloadedOnlyUseCase;
  final UpdateSettingIncognitoUseCase _updateSettingIncognitoUseCase;
  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenJobUseCase listenJobUseCase,
    required ListenSettingDownloadedOnlyUseCase
    listenSettingDownloadedOnlyUseCase,
    required UpdateSettingDownloadedOnlyUseCase
    updateSettingDownloadedOnlyUseCase,
    required ListenSettingIncognitoUseCase listenSettingIncognitoUseCase,
    required UpdateSettingIncognitoUseCase updateSettingIncognitoUseCase,
  }) : _updateSettingDownloadedOnlyUseCase = updateSettingDownloadedOnlyUseCase,
       _updateSettingIncognitoUseCase = updateSettingIncognitoUseCase,
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
    addSubscription(
      listenSettingIncognitoUseCase.incognitoState.distinct().listen(
        (value) => emit(state.copyWith(isIncognito: value)),
      ),
    );
  }

  void toggleIsDownloadedOnly() {
    _updateSettingDownloadedOnlyUseCase.updateDownloadedOnly(
      downloadedOnly: !state.isDownloadedOnly,
    );
  }

  void toggleIsIncognito() {
    _updateSettingIncognitoUseCase.updateIncognito(
      incognito: !state.isIncognito,
    );
  }
}
