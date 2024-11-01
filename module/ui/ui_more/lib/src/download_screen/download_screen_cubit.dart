import 'dart:io';

import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'download_screen_state.dart';

class DownloadScreenCubit extends Cubit<DownloadScreenState>
    with AutoSubscriptionMixin {
  final SetDownloadPathUseCase _setDownloadPathUseCase;

  DownloadScreenCubit({
    DownloadScreenState initialState = const DownloadScreenState(),
    required GetRootPathUseCase getRootPathUseCase,
    required ListenDownloadPathUseCase listenDownloadPathUseCase,
    required SetDownloadPathUseCase setDownloadPathUseCase,
  })  : _setDownloadPathUseCase = setDownloadPathUseCase,
        super(initialState.copyWith(rootPath: getRootPathUseCase.rootPath)) {
    addSubscription(
      listenDownloadPathUseCase.downloadPathStream.listen(_updateDownloadPath),
    );
  }

  void _updateDownloadPath(Directory path) {
    emit(state.copyWith(downloadPath: path));
  }

  void setDownloadPath(String path) {
    _setDownloadPathUseCase.setDownloadPath(path);
  }
}
