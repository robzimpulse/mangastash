import 'package:equatable/equatable.dart';

class BackupRestoreScreenState extends Equatable {

  final String? path;

  const BackupRestoreScreenState({this.path});

  @override
  List<Object?> get props => [path];

  BackupRestoreScreenState copyWith ({String? path}) {
    return BackupRestoreScreenState(path: path ?? this.path);
  }

}