import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_io/io.dart';

import '../../use_case/get_backup_path_usecase.dart';
import '../../use_case/get_download_path_usecase.dart';
import '../../use_case/get_root_path_usecase.dart';
import '../../use_case/update_root_path_usecase.dart';

class PathManager
    implements
        GetRootPathUseCase,
        UpdateRootPathUseCase,
        GetBackupPathUseCase,
        GetDownloadPathUseCase {
  final Directory _defaultRootDirectory;
  Directory? _rootDirectory;
  Directory? _backupDirectory;
  Directory? _downloadDirectory;

  PathManager._({
    required Directory defaultRootDirectory,
    Directory? rootDirectory,
    Directory? backupDirectory,
    Directory? downloadDirectory,
  }) : _rootDirectory = rootDirectory,
       _backupDirectory = backupDirectory,
       _downloadDirectory = downloadDirectory,
       _defaultRootDirectory = defaultRootDirectory;

  static Future<PathManager> create() async {
    final root = await getApplicationDocumentsDirectory();

    return PathManager._(
      rootDirectory: root,
      defaultRootDirectory: root,
      downloadDirectory: await Directory(
        join(root.path, 'download'),
      ).create(recursive: true),
      backupDirectory: await Directory(
        join(root.path, 'backup'),
      ).create(recursive: true),
    );
  }

  @override
  Future<void> updateRootPath(String path) async {
    if (kIsWeb) return;

    await [Permission.manageExternalStorage, Permission.storage].request();

    final isGranted = await Future.wait([
      Permission.manageExternalStorage.isGranted,
      Permission.storage.isGranted,
    ]);

    if (!isGranted.contains(true)) return;

    final root = Directory.fromUri(Uri.file(path));
    final backup = Directory(join(root.path, 'backup'));
    final download = Directory(join(root.path, 'download'));

    try {
      /// test create folder on [path] if success we set it as root directory
      /// along with backup and download folder
      await Future.wait([
        root.create(recursive: true),
        backup.create(recursive: true),
        download.create(recursive: true),
      ]);
    } catch (e) {
      /// failed to create folder
      return;
    }

    _rootDirectory = root;
    _backupDirectory = backup;
    _downloadDirectory = backup;
  }

  @override
  Directory get defaultRootDirectory => _defaultRootDirectory;

  @override
  Directory? get rootPath => _rootDirectory;

  @override
  Directory? get backupPath => _backupDirectory;

  @override
  Directory? get downloadPath => _downloadDirectory;
}
