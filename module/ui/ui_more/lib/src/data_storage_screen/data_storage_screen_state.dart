import 'package:equatable/equatable.dart';
import 'package:universal_io/universal_io.dart';

class DataStorageScreenState extends Equatable {
  const DataStorageScreenState({
    this.isLoadingBackup = false,
    this.listBackup = const [],
    this.isLoadingListBackup = false,
    this.rootPath,
    this.isDefaultRootPath = true,
  });

  final bool isLoadingBackup;
  final List<FileSystemEntity> listBackup;
  final bool isLoadingListBackup;
  final Directory? rootPath;
  final bool isDefaultRootPath;

  @override
  List<Object?> get props => [
    isLoadingBackup,
    listBackup,
    isLoadingListBackup,
    rootPath,
    isDefaultRootPath,
  ];

  DataStorageScreenState copyWith({
    bool? isLoadingBackup,
    List<FileSystemEntity>? listBackup,
    bool? isLoadingListBackup,
    Directory? rootPath,
    bool? isDefaultRootPath,
  }) {
    return DataStorageScreenState(
      isLoadingBackup: isLoadingBackup ?? this.isLoadingBackup,
      listBackup: listBackup ?? this.listBackup,
      isLoadingListBackup: isLoadingListBackup ?? this.isLoadingListBackup,
      rootPath: rootPath ?? this.rootPath,
      isDefaultRootPath: isDefaultRootPath ?? this.isDefaultRootPath,
    );
  }
}
