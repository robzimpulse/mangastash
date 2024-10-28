import 'dart:io';

import 'package:equatable/equatable.dart';

class BackupRestoreScreenState extends Equatable {

  final Directory? root;

  const BackupRestoreScreenState({this.root});

  @override
  List<Object?> get props => [root];

  BackupRestoreScreenState copyWith ({Directory? root}) {
    return BackupRestoreScreenState(root: root ?? this.root);
  }

}