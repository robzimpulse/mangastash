import 'dart:io';

import 'package:equatable/equatable.dart';

class DownloadScreenState extends Equatable {
  final Directory? downloadPath;

  final Directory? rootPath;

  const DownloadScreenState({this.downloadPath, this.rootPath});

  @override
  List<Object?> get props => [downloadPath, rootPath];

  DownloadScreenState copyWith({
    Directory? downloadPath,
    Directory? rootPath,
  }) {
    return DownloadScreenState(
      downloadPath: downloadPath ?? this.downloadPath,
      rootPath: rootPath ?? this.rootPath,
    );
  }
}
