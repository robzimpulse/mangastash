import 'dart:io';

import 'package:equatable/equatable.dart';

class BackupRestoreScreenState extends Equatable {
  final Directory? backupPath;

  final Directory? rootPath;

  const BackupRestoreScreenState({this.backupPath, this.rootPath});

  @override
  List<Object?> get props => [backupPath, rootPath];

  BackupRestoreScreenState copyWith({
    Directory? backupPath,
    Directory? rootPath,
  }) {
    return BackupRestoreScreenState(
      backupPath: backupPath ?? this.backupPath,
      rootPath: rootPath ?? this.rootPath,
    );
  }
}
