import 'package:equatable/equatable.dart';
import 'package:universal_io/universal_io.dart';

class BackupRestoreScreenState extends Equatable {
  const BackupRestoreScreenState({this.backupPath, this.rootPath});

  final Directory? backupPath;

  final Directory? rootPath;

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
