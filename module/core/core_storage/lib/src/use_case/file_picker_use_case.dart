import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'get_root_path_use_case.dart';

class FilePickerUseCase {
  final GetRootPathUseCase _getRootPathUseCase;

  const FilePickerUseCase({required GetRootPathUseCase getRootPathUseCase})
    : _getRootPathUseCase = getRootPathUseCase;

  Future<Uint8List?> execute({required List<String> allowedExtensions}) async {
    String initialDirectory = _getRootPathUseCase.rootPath.path;

    if (defaultTargetPlatform == TargetPlatform.android) {
      initialDirectory = '/storage/emulated/0';
    }

    if (!kIsWeb) {
      await [Permission.manageExternalStorage, Permission.storage].request();

      final isGranted = await Future.wait([
        Permission.manageExternalStorage.isGranted,
        Permission.storage.isGranted,
      ]);

      if (!isGranted.contains(true)) return null;
    }

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select file',
      initialDirectory: initialDirectory,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withReadStream: true,
    );

    final file = result?.files.firstOrNull;
    final bytes = await file?.readStream?.toList();
    if (bytes == null) return null;
    return Uint8List.fromList([...bytes.expand((e) => e)]);
  }
}
