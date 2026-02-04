import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'get_root_path_use_case.dart';

class FileSaverUseCase {
  final GetRootPathUseCase _getRootPathUseCase;

  const FileSaverUseCase({required GetRootPathUseCase getRootPathUseCase})
    : _getRootPathUseCase = getRootPathUseCase;

  Future<void> execute({String? filename, required Uint8List data}) async {
    if (!kIsWeb) {
      await [Permission.manageExternalStorage, Permission.storage].request();

      final isGranted = await Future.wait([
        Permission.manageExternalStorage.isGranted,
        Permission.storage.isGranted,
      ]);

      if (!isGranted.contains(true)) return;
    }

    await FilePicker.platform.saveFile(
      dialogTitle: 'Save to file',
      fileName: filename,
      initialDirectory:
          (defaultTargetPlatform == TargetPlatform.android)
              ? '/storage/emulated/0'
              : _getRootPathUseCase.rootPath.path,
      type: FileType.custom,
      allowedExtensions: ['.sqlite'],
      bytes: data,
    );
  }
}
