import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../use_case/get_root_path_use_case.dart';

class RootPathManager implements GetRootPathUseCase {
  final Directory _rootDirectory;

  RootPathManager._({required Directory rootDirectory})
      : _rootDirectory = rootDirectory;

  static Future<RootPathManager> create() async {
    final rootDirectory = await getApplicationDocumentsDirectory();
    return RootPathManager._(rootDirectory: rootDirectory);
  }

  @override
  Directory get rootPath => _rootDirectory;
}
