import 'package:equatable/equatable.dart';
import 'package:universal_io/universal_io.dart';

class DataStorageScreenState extends Equatable {
  const DataStorageScreenState({
    this.isLoadingBackup = false,
    this.listBackup = const [],
    this.isLoadingListBackup = false,
  });

  final bool isLoadingBackup;

  final List<FileSystemEntity> listBackup;
  final bool isLoadingListBackup;

  @override
  List<Object?> get props => [isLoadingBackup, listBackup, isLoadingListBackup];

  DataStorageScreenState copyWith({
    bool? isLoadingBackup,
    List<FileSystemEntity>? listBackup,
    bool? isLoadingListBackup,
  }) {
    return DataStorageScreenState(
      isLoadingBackup: isLoadingBackup ?? this.isLoadingBackup,
      listBackup: listBackup ?? this.listBackup,
      isLoadingListBackup: isLoadingListBackup ?? this.isLoadingListBackup,
    );
  }
}
