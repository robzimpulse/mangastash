import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../../use_case/get_backup_path_usecase.dart';
import '../../use_case/get_download_path_usecase.dart';
import '../../use_case/get_root_path_use_case.dart';

class PathManager
    implements
        GetRootPathUseCase,
        GetBackupPathUseCase,
        GetDownloadPathUseCase {
  final Directory? _rootDirectory;
  final Directory? _androidRootDirectory;
  final Directory? _backupDirectory;
  final Directory? _downloadDirectory;

  PathManager._({
    Directory? rootDirectory,
    Directory? androidRootDirectory,
    Directory? backupDirectory,
    Directory? downloadDirectory,
  }) : _rootDirectory = rootDirectory,
       _androidRootDirectory = androidRootDirectory,
       _backupDirectory = backupDirectory,
       _downloadDirectory = downloadDirectory;

  static Future<PathManager> create() async {
    Directory? root;
    Directory? androidRoot;
    Directory? backup;
    Directory? download;

    if (!kIsWeb) {
      root = await getApplicationDocumentsDirectory();
      backup = Directory(join(root.path, 'backup'));
      download = Directory(join(root.path, 'download'));
      if (defaultTargetPlatform == TargetPlatform.android) {
        androidRoot = Directory.fromUri(Uri.file('/storage/emulated/0'));
      }
    }

    if (backup != null && !await backup.exists()) {
      await backup.create(recursive: true);
    }

    if (download != null && !await download.exists()) {
      await download.create(recursive: true);
    }

    if (androidRoot != null && !await androidRoot.exists()) {
      androidRoot = null;
    }

    return PathManager._(
      rootDirectory: root,
      downloadDirectory: download,
      backupDirectory: backup,
      androidRootDirectory: androidRoot,
    );
  }

  @override
  Directory? get rootPath => _rootDirectory;

  @override
  Directory? get androidRootPath => _androidRootDirectory;

  @override
  Directory? get backupPath => _backupDirectory;

  @override
  Directory? get downloadPath => _downloadDirectory;
}
