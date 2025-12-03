import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:universal_io/universal_io.dart';

import 'backup_restore_screen_state.dart';

class BackupRestoreScreenCubit extends Cubit<BackupRestoreScreenState>
    with AutoSubscriptionMixin {
  final RestoreDatabaseUseCase _restoreDatabaseUseCase;
  final BackupDatabaseUseCase _backupDatabaseUseCase;
  final SetBackupPathUseCase _setBackupPathUseCase;
  final FilesystemPickerUsecase _filesystemPickerUsecase;

  BackupRestoreScreenCubit({
    BackupRestoreScreenState initialState = const BackupRestoreScreenState(),
    required BackupDatabaseUseCase backupDatabaseUseCase,
    required RestoreDatabaseUseCase restoreDatabaseUseCase,
    required ListenBackupPathUseCase listenBackupPathUseCase,
    required SetBackupPathUseCase setBackupPathUseCase,
    required FilesystemPickerUsecase filesystemPickerUsecase,
  }) : _backupDatabaseUseCase = backupDatabaseUseCase,
       _setBackupPathUseCase = setBackupPathUseCase,
       _restoreDatabaseUseCase = restoreDatabaseUseCase,
       _filesystemPickerUsecase = filesystemPickerUsecase,
       super(initialState) {
    addSubscription(
      listenBackupPathUseCase.backupPathStream.listen(
        (e) => emit(state.copyWith(backupPath: e)),
      ),
    );
  }

  Future<Exception?> setBackupPath(BuildContext context) async {
    final directory = await _filesystemPickerUsecase.directory(context);

    if (directory is Success<Directory>) {
      _setBackupPathUseCase.setBackupPath(directory.data.path);
      return null;
    }

    if (directory is Error<Directory>) {
      return directory.error;
    }

    return Exception('Something went wrong');
  }

  Future<Exception?> backup(BuildContext context) async {
    final directory = await _filesystemPickerUsecase.directory(context);

    if (directory is Success<Directory>) {
      await _backupDatabaseUseCase.execute(directory: directory.data);
      return null;
    }

    if (directory is Error<Directory>) {
      return directory.error;
    }

    return Exception('Something went wrong');
  }

  Future<Exception?> restore(BuildContext context) async {
    final file = await _filesystemPickerUsecase.file(context);

    if (file is Success<File>) {
      await _restoreDatabaseUseCase.execute(file: file.data);
      return null;
    }

    if (file is Error<File>) {
      return file.error;
    }

    return Exception('Something went wrong');
  }
}
