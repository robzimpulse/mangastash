import 'dart:io';

import 'package:equatable/equatable.dart';

class BackupRestoreScreenState extends Equatable {
  final Directory? downloadPath;

  final Directory? rootPath;

  const BackupRestoreScreenState({this.downloadPath, this.rootPath});

  @override
  List<Object?> get props => [downloadPath, rootPath];

  BackupRestoreScreenState copyWith({
    Directory? downloadPath,
    Directory? rootPath,
  }) {
    return BackupRestoreScreenState(
      downloadPath: downloadPath ?? this.downloadPath,
      rootPath: rootPath ?? this.rootPath,
    );
  }
}
