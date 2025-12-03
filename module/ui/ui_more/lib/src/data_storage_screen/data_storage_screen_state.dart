import 'package:equatable/equatable.dart';
import 'package:universal_io/universal_io.dart';

class DataStorageScreenState extends Equatable {
  const DataStorageScreenState({this.backupPath});

  final Directory? backupPath;

  @override
  List<Object?> get props => [backupPath];

  DataStorageScreenState copyWith({Directory? backupPath}) {
    return DataStorageScreenState(backupPath: backupPath ?? this.backupPath);
  }
}
