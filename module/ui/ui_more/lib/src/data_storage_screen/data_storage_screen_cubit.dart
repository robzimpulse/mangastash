import 'package:core_storage/core_storage.dart';
import 'package:path/path.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:universal_io/universal_io.dart';

import 'data_storage_screen_state.dart';

class DataStorageScreenCubit extends Cubit<DataStorageScreenState>
    with AutoSubscriptionMixin {
  final GetBackupPathUseCase _getBackupPathUseCase;
  final UpdateRootPathUseCase _updateRootPathUseCase;
  final GetRootPathUseCase _getRootPathUseCase;
  final AppDatabase _database;

  DataStorageScreenCubit({
    DataStorageScreenState initialState = const DataStorageScreenState(),
    required GetBackupPathUseCase getBackupPathUseCase,
    required GetRootPathUseCase getRootPathUseCase,
    required UpdateRootPathUseCase updateRootPathUseCase,
    required AppDatabase database,
  }) : _getBackupPathUseCase = getBackupPathUseCase,
       _updateRootPathUseCase = updateRootPathUseCase,
       _getRootPathUseCase = getRootPathUseCase,
       _database = database,
       super(
         initialState.copyWith(
           rootPath: getRootPathUseCase.rootPath,
           isDefaultRootPath: getRootPathUseCase.isDefault,
         ),
       );

  Future<void> addBackup() async {
    final dir = _getBackupPathUseCase.backupPath;
    if (dir == null) return;
    emit(state.copyWith(isLoadingBackup: true));
    final filename = '${DateTime.timestamp().microsecondsSinceEpoch}.sqlite';
    final file = await _database.backup(filename: filename);
    await file.copy(join(dir.path, filename));
    await file.delete();
    emit(state.copyWith(isLoadingBackup: false));
    refreshListBackup();
  }

  Future<void> refreshListBackup() async {
    final dir = _getBackupPathUseCase.backupPath;
    if (dir == null) return;
    emit(state.copyWith(isLoadingListBackup: true));
    final files = await dir.list().toList();
    emit(state.copyWith(listBackup: files, isLoadingListBackup: false));
  }

  Future<void> deleteBackup(FileSystemEntity file) async {
    await file.delete();
    await refreshListBackup();
  }

  Future<void> restoreBackup(FileSystemEntity file) async {
    await _database.restore(file: File(file.path));
  }

  Future<void> updateStoragePath(String path) async {
    await _updateRootPathUseCase.updateRootPath(path);
    emit(
      state.copyWith(
        rootPath: _getRootPathUseCase.rootPath,
        isDefaultRootPath: _getRootPathUseCase.isDefault,
      ),
    );
    refreshListBackup();
  }

  Future<void> resetStoragePath() async {
    await updateStoragePath(_getRootPathUseCase.defaultRootDirectory.path);
  }
}
