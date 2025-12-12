import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/universal_io.dart';

import 'get_root_path_use_case.dart';

class FilesystemPickerUseCase {
  final GetRootPathUseCase _getRootPathUseCase;

  const FilesystemPickerUseCase({
    required GetRootPathUseCase getRootPathUseCase,
  }) : _getRootPathUseCase = getRootPathUseCase;

  Future<Directory?> directory(BuildContext context) async {
    final path = await _picker(
      context,
      type: FilesystemType.folder,
      contextActions: [FilesystemPickerNewFolderContextAction()],
    );
    if (path == null) return null;
    return Directory(path);
  }

  Future<File?> file(BuildContext context) async {
    final path = await _picker(context, type: FilesystemType.file);
    if (path == null) return null;
    return File(path);
  }

  Future<String?> _picker(
    BuildContext context, {
    List<FilesystemPickerContextAction> contextActions = const [],
    FilesystemType? type,
  }) {
    return FilesystemPicker.openDialog(
      title: 'Select file or folder',
      context: context,
      rootDirectory:
          defaultTargetPlatform == TargetPlatform.android
              ? Directory('/storage/emulated/0')
              : _getRootPathUseCase.rootPath,
      fsType: type,
      pickText: 'Select current folder',
      contextActions: contextActions,
      allowedExtensions: ['.sqlite'],
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
