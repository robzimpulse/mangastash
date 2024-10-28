import 'dart:io';

import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState>
    with AutoSubscriptionMixin {
  final SetDownloadPathUseCase _setDownloadPathUseCase;

  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required ListenDownloadPathUseCase listenDownloadPathUseCase,
    required GetRootPathUseCase getRootPathUseCase,
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
