import 'package:file/file.dart';

import '../../use_case/get_backup_path_use_case.dart';
import '../../use_case/get_download_path_use_case.dart';
import '../../use_case/get_root_path_use_case.dart';
import 'adapter/filesystem_adapter.dart'
    if (dart.library.js_interop) 'adapter/filesystem_web.dart'
    if (dart.library.io) 'adapter/filesystem_io.dart';

class PathManager
    implements
        GetRootPathUseCase,
        GetBackupPathUseCase,
        GetDownloadPathUseCase {
  final Directory _rootDirectory;
  final Directory _backupDirectory;
  final Directory _downloadDirectory;

  PathManager._({
    required Directory rootDirectory,
    required Directory backupDirectory,
    required Directory downloadDirectory,
  }) : _rootDirectory = rootDirectory,
       _backupDirectory = backupDirectory,
       _downloadDirectory = downloadDirectory;

  static Future<PathManager> create() async {
    final root = await rootDirectory();
    final download = root.childDirectory('download');
    final backup = root.childDirectory('backup');

    return PathManager._(
      rootDirectory: root,
      downloadDirectory: await download.create(recursive: true),
      backupDirectory: await backup.create(recursive: true),
    );
  }

  @override
  Directory get rootPath => _rootDirectory;

  @override
  Directory get backupPath => _backupDirectory;

  @override
  Directory get downloadPath => _downloadDirectory;
}
