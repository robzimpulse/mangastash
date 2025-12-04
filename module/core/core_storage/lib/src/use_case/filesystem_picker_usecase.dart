import 'package:core_network/core_network.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/universal_io.dart';

import 'get_root_path_use_case.dart';
import 'listen_backup_path_use_case.dart';

class FilesystemPickerUsecase {
  final GetRootPathUseCase _getRootPathUseCase;
  final ListenBackupPathUseCase _listenBackupPathUseCase;

  FilesystemPickerUsecase({
    required GetRootPathUseCase getRootPathUseCase,
    required ListenBackupPathUseCase listenBackupPathUseCase,
  }) : _getRootPathUseCase = getRootPathUseCase,
       _listenBackupPathUseCase = listenBackupPathUseCase;

  Future<Result<Directory>> directory(BuildContext context) async {
    try {
      final path = await picker(
        context,
        FilesystemType.folder,
        contextActions: [FilesystemPickerNewFolderContextAction()],
      );
      if (path == null) throw Exception('Path is null');
      return Success(Directory.fromUri(Uri.file(path)));
    } catch (e) {
      return Error(e);
    }
  }

  Future<Result<File>> file(BuildContext context) async {
    try {
      final path = await picker(context, FilesystemType.file);
      if (path == null) throw Exception('Path is null');
      return Success(File(path));
    } catch (e) {
      return Error(e);
    }
  }

  Future<String?> picker(
    BuildContext context,
    FilesystemType? type, {
    List<FilesystemPickerContextAction> contextActions = const [],
  }) {
    return FilesystemPicker.openDialog(
      title: 'Select file or folder',
      context: context,
      rootDirectory: _getRootPathUseCase.rootPath,
      directory: _listenBackupPathUseCase.backupPathStream.valueOrNull,
      fsType: type,
      pickText: 'Select current folder',
      contextActions: contextActions,
      requestPermission: () async {
        await [Permission.manageExternalStorage, Permission.storage].request();

        final isGranted = await Future.wait([
          Permission.manageExternalStorage.isGranted,
          Permission.storage.isGranted,
        ]);

        return isGranted.contains(true);
      },
    );
  }
}
