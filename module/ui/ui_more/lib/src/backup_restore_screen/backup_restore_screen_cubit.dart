import 'dart:io';

import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState>
    with AutoSubscriptionMixin {
  final SetBackupPathUseCase _setBackupPathUseCase;

  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required GetRootPathUseCase getRootPathUseCase,
    required ListenBackupPathUseCase listenBackupPathUseCase,
    required SetBackupPathUseCase setBackupPathUseCase,
  })  : _setBackupPathUseCase = setBackupPathUseCase,
        super(initialState.copyWith(rootPath: getRootPathUseCase.rootPath)) {
    addSubscription(
      listenBackupPathUseCase.backupPathStream
          .distinct()
          .listen(_updateBackupPath),
    );
  }

  void _updateBackupPath(Directory path) {
    emit(state.copyWith(backupPath: path));
  }

  void setBackupPath(String path) {
    _setBackupPathUseCase.setBackupPath(path);
  }
}
