import 'package:equatable/equatable.dart';
import 'package:file/file.dart';

/// Immutable UI state for the Data & Storage screen.
class DataStorageScreenState extends Equatable {
  const DataStorageScreenState({
    this.isLoadingBackup = false,
    this.isRestoring = false,
    this.listBackup = const [],
    this.isLoadingListBackup = false,
  });

  final bool isLoadingBackup;

  /// True while a backup restore is being written to the database.
  final bool isRestoring;
  final List<File> listBackup;
  final bool isLoadingListBackup;

  @override
  List<Object?> get props => [
    isLoadingBackup,
    isRestoring,
    listBackup,
    isLoadingListBackup,
  ];

  DataStorageScreenState copyWith({
    bool? isLoadingBackup,
    bool? isRestoring,
    List<File>? listBackup,
    bool? isLoadingListBackup,
  }) {
    return DataStorageScreenState(
      isLoadingBackup: isLoadingBackup ?? this.isLoadingBackup,
      isRestoring: isRestoring ?? this.isRestoring,
      listBackup: listBackup ?? this.listBackup,
      isLoadingListBackup: isLoadingListBackup ?? this.isLoadingListBackup,
    );
  }
}
