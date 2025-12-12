import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../../use_case/get_backup_path_use_case.dart';
import '../../use_case/get_download_path_use_case.dart';
import '../../use_case/get_root_path_use_case.dart';

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
    final root = await getApplicationDocumentsDirectory();

    return PathManager._(
      rootDirectory: root,
      downloadDirectory: await Directory(
        join(root.path, 'download'),
      ).create(recursive: true),
      backupDirectory: await Directory(
        join(root.path, 'backup'),
      ).create(recursive: true),
    );
  }

  @override
  Directory? get rootPath => _rootDirectory;

  @override
  Directory? get backupPath => _backupDirectory;

  @override
  Directory? get downloadPath => _downloadDirectory;
}
