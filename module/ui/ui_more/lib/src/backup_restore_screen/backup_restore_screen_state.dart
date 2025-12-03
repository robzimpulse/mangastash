import 'package:equatable/equatable.dart';
import 'package:universal_io/universal_io.dart';

class BackupRestoreScreenState extends Equatable {
  const BackupRestoreScreenState({this.backupPath});

  final Directory? backupPath;

  @override
  List<Object?> get props => [backupPath];

  BackupRestoreScreenState copyWith({Directory? backupPath}) {
    return BackupRestoreScreenState(backupPath: backupPath ?? this.backupPath);
  }
}
