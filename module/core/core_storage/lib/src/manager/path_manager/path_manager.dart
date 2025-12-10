import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final Directory? _backupDirectory;
  final Directory? _downloadDirectory;

  PathManager._({
    Directory? rootDirectory,
    Directory? backupDirectory,
    Directory? downloadDirectory,
  }) : _rootDirectory = rootDirectory,
       _backupDirectory = backupDirectory,
       _downloadDirectory = downloadDirectory;

  static Future<PathManager> create() async {
    Directory? root;
    Directory? backup;
    Directory? download;

    if (!kIsWeb) {
      /// if platform were android, try to check root on `/storage/emulated/0`
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.manageExternalStorage, Permission.storage].request();

        final isGranted = await Future.wait([
          Permission.manageExternalStorage.isGranted,
          Permission.storage.isGranted,
        ]);

        final androidRoot = Directory.fromUri(
          Uri.file('/storage/emulated/0/Mangastash'),
        );
        try {
          if (!isGranted.contains(true)) throw Exception('Permission denied');

          /// test create folder on path `/storage/emulated/0`, if success we
          /// set it as android root directory
          await androidRoot.create(recursive: true);

          /// set root to android root
          root = androidRoot;
        } catch (e) {
          /// fallback to application documents directory
          root = await getApplicationDocumentsDirectory();
        }
      } else {
        root = await getApplicationDocumentsDirectory();
      }

      backup = Directory(join(root.path, 'backup'));
      download = Directory(join(root.path, 'download'));
    }

    if (backup != null && !await backup.exists()) {
      await backup.create(recursive: true);
    }

    if (download != null && !await download.exists()) {
      await download.create(recursive: true);
    }

    return PathManager._(
      rootDirectory: root,
      downloadDirectory: download,
      backupDirectory: backup,
    );
  }

  @override
  Directory? get rootPath => _rootDirectory;

  @override
  Directory? get backupPath => _backupDirectory;

  @override
  Directory? get downloadPath => _downloadDirectory;
}
