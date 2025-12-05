import 'package:core_network/core_network.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/universal_io.dart';

import 'get_root_path_use_case.dart';

class FilesystemPickerUseCase {
  final GetRootPathUseCase _getRootPathUseCase;

  const FilesystemPickerUseCase({
    required GetRootPathUseCase getRootPathUseCase,
  }) : _getRootPathUseCase = getRootPathUseCase;

  Future<Result<File>> file(BuildContext context) async {
    try {
      final path = await _picker(
        context,
        type: FilesystemType.file,
        rootDirectory: _getRootPathUseCase.rootForPickFile,
      );
      if (path == null) throw Exception('Path is null');
      return Success(File(path));
    } catch (e) {
      return Error(e);
    }
  }

  Future<String?> _picker(
    BuildContext context, {
    List<FilesystemPickerContextAction> contextActions = const [],
    FilesystemType? type,
    Directory? rootDirectory,
  }) {
    return FilesystemPicker.openDialog(
      title: 'Select file or folder',
      context: context,
      rootDirectory: rootDirectory,
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
