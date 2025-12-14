import 'dart:typed_data';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'data_storage_screen_state.dart';

class DataStorageScreenCubit extends Cubit<DataStorageScreenState>
    with AutoSubscriptionMixin {
  final GetBackupPathUseCase _getBackupPathUseCase;
  final AppDatabase _database;

  DataStorageScreenCubit({
    DataStorageScreenState initialState = const DataStorageScreenState(),
    required GetBackupPathUseCase getBackupPathUseCase,
    required AppDatabase database,
  }) : _getBackupPathUseCase = getBackupPathUseCase,
       _database = database,
       super(initialState);

  Future<void> addBackupFromDatabase() async {
    await addBackupFromData(data: await _database.backup());
  }

  Future<void> addBackupFromData({required Uint8List data}) async {
    final filename = '${DateTime.timestamp().microsecondsSinceEpoch}.sqlite';
    final dir = _getBackupPathUseCase.backupPath;
    emit(state.copyWith(isLoadingBackup: true));
    await dir.childFile(filename).writeAsBytes(data);
    emit(state.copyWith(isLoadingBackup: false));
    refreshListBackup();
  }

  Future<void> refreshListBackup() async {
    final dir = _getBackupPathUseCase.backupPath;
    emit(state.copyWith(isLoadingListBackup: true));
    final files = await dir.list().toList();
    emit(
      state.copyWith(
        listBackup: [...files.map((e) => e.castOrNull<File>()).nonNulls],
        isLoadingListBackup: false,
      ),
    );
  }

  Future<void> deleteBackup(File file) async {
    await file.delete();
    await refreshListBackup();
  }

  Future<void> restoreBackup(File file) async {
    await _database.restore(data: await file.readAsBytes());
  }
}
