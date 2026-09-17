import 'dart:typed_data';

import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'data_storage_screen_state.dart';

class DataStorageScreenCubit extends Cubit<DataStorageScreenState>
    with AutoSubscriptionMixin {
  static const _maxBackups = 10;

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

  /// Writes [data] as a new timestamped backup file, prunes old backups past
  /// the cap of 10, then refreshes the list.
  ///
  /// Throws when writing fails; [isLoadingBackup] is always reset.
  Future<void> addBackupFromData({required Uint8List data}) async {
    final filename = '${DateTime.timestamp().microsecondsSinceEpoch}.sqlite';
    final dir = _getBackupPathUseCase.backupPath;
    emit(state.copyWith(isLoadingBackup: true));
    try {
      await dir.childFile(filename).writeAsBytes(data);
      await _pruneOldBackups(dir);
    } finally {
      emit(state.copyWith(isLoadingBackup: false));
    }
    refreshListBackup();
  }

  /// Keeps only the newest [_maxBackups] backups (timestamp names sort
  /// chronologically) and deletes the rest. Files that are not backups
  /// (anything not named `*.sqlite`) are left alone.
  Future<void> _pruneOldBackups(Directory dir) async {
    final files = await _listBackupFiles(dir);
    if (files.length <= _maxBackups) return;
    for (final file in files.take(files.length - _maxBackups)) {
      await file.delete();
    }
  }

  Future<void> refreshListBackup() async {
    final dir = _getBackupPathUseCase.backupPath;
    emit(state.copyWith(isLoadingListBackup: true));
    final files = await _listBackupFiles(dir);
    emit(
      state.copyWith(listBackup: files, isLoadingListBackup: false),
    );
  }

  /// Backup files of [dir] named `*.sqlite`, sorted oldest-first — the same
  /// set the rotation prunes, so the list and the cap stay consistent.
  Future<List<File>> _listBackupFiles(Directory dir) async {
    return (await dir.list().toList())
        .whereType<File>()
        .where((file) => file.path.endsWith('.sqlite'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Future<void> deleteBackup(File file) async {
    await file.delete();
    await refreshListBackup();
  }

  /// Restores the database from [file].
  ///
  /// Throws when reading or restoring fails; [isRestoring] is always reset.
  /// The caller must restart the app afterwards to pick up the new data.
  Future<void> restoreBackup(File file) async {
    emit(state.copyWith(isRestoring: true));
    try {
      await _database.restore(data: await file.readAsBytes());
    } finally {
      emit(state.copyWith(isRestoring: false));
    }
  }
}
