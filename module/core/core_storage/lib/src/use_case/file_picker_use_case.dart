import 'package:file/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'get_root_path_use_case.dart';

class FilePickerUseCase {
  final GetRootPathUseCase _getRootPathUseCase;

  const FilePickerUseCase({required GetRootPathUseCase getRootPathUseCase})
    : _getRootPathUseCase = getRootPathUseCase;

  Future<Uint8List?> execute(BuildContext context) async {
    final Directory root;
    if (defaultTargetPlatform == TargetPlatform.android) {
      root = _getRootPathUseCase.rootPath.fileSystem.directory(
        '/storage/emulated/0',
      );
    } else {
      root = _getRootPathUseCase.rootPath;
    }

    if (kIsWeb) return _pickerWeb(root);
    return _pickerIO(context, root);
  }

  Future<Uint8List?> _pickerWeb(Directory initialDirectory) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select file',
      initialDirectory: initialDirectory.path,
      type: FileType.custom,
      allowedExtensions: ['.sqlite'],
    );
    if (result == null) return null;

    return result.files.firstOrNull?.bytes;
  }

  Future<Uint8List?> _pickerIO(
    BuildContext context,
    Directory initialDirectory,
  ) async {
    final path = await FilesystemPicker.openDialog(
      title: 'Select file or folder',
      context: context,
      rootDirectory: initialDirectory,
      fsType: FilesystemType.file,
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

    if (path == null) return null;

    return _getRootPathUseCase.rootPath.fileSystem.file(path).readAsBytes();
  }
}
