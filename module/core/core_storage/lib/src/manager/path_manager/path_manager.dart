import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

import '../../storage/shared_preferences_storage.dart';
import '../../use_case/get_root_path_use_case.dart';
import '../../use_case/listen_backup_path_use_case.dart';
import '../../use_case/listen_download_path_use_case.dart';
import '../../use_case/set_backup_path_use_case.dart';
import '../../use_case/set_download_path_use_case.dart';

import 'adapter/application_documents_directory_adapter.dart'
    if (dart.library.io) 'adapter/application_documents_directory_native.dart'
    if (dart.library.js) 'adapter/application_documents_directory_web.dart';

class PathManager
    implements
        ListenDownloadPathUseCase,
        SetDownloadPathUseCase,
        ListenBackupPathUseCase,
        SetBackupPathUseCase,
        GetRootPathUseCase {
  final Directory _rootDirectory;

  final BehaviorSubject<Directory> _downloadDirectory;

  final BehaviorSubject<Directory> _backupDirectory;

  final SharedPreferencesStorage _storage;

  static const _downloadPathKey = 'download_path';
  static const _backupPathKey = 'backup_path';

  PathManager._({
    required Directory rootDirectory,
    required Directory backupDirectory,
    required Directory downloadDirectory,
    required SharedPreferencesStorage storage,
  })  : _downloadDirectory = BehaviorSubject.seeded(downloadDirectory),
        _backupDirectory = BehaviorSubject.seeded(backupDirectory),
        _storage = storage,
        _rootDirectory = rootDirectory;

  static Future<PathManager> create({
    required SharedPreferencesStorage storage,
  }) async {
    const rootPath = '/storage/emulated/0';

    final root = Directory.fromUri(Uri.file(rootPath));
    final rootDirectory = (await root.exists() && Platform.isAndroid)
        ? root
        : await applicationDocumentsDirectory();

    final defaultPath = Directory.fromUri(Uri.file('$rootPath/Mangastash'));
    final defaultDirectory = (await defaultPath.exists() && Platform.isAndroid)
        ? defaultPath
        : rootDirectory;

    final downloadPath = storage.getString(_downloadPathKey);
    final candidateDownloadPath =
        downloadPath != null ? Directory.fromUri(Uri.file(downloadPath)) : null;
    final downloadDirectory = candidateDownloadPath != null
        ? await candidateDownloadPath.exists()
            ? candidateDownloadPath
            : defaultDirectory
        : defaultDirectory;

    final backupPath = storage.getString(_backupPathKey);
    final candidateBackupPath =
        backupPath != null ? Directory.fromUri(Uri.file(backupPath)) : null;
    final backupDirectory = candidateBackupPath != null
        ? await candidateBackupPath.exists()
            ? candidateBackupPath
            : defaultDirectory
        : defaultDirectory;

    return PathManager._(
      rootDirectory: rootDirectory,
      downloadDirectory: downloadDirectory,
      backupDirectory: backupDirectory,
      storage: storage,
    );
  }

  @override
  void setDownloadPath(String path) async {
    if (path.isEmpty) return;
    final candidate = Directory.fromUri(Uri.file(path));
    final isExists = await candidate.exists();
    if (!isExists) return;
    _storage.setString(_downloadPathKey, candidate.path);
    _downloadDirectory.add(candidate);
  }

  @override
  ValueStream<Directory> get downloadPathStream => _downloadDirectory.stream;

  @override
  Directory get rootPath => _rootDirectory;

  @override
  ValueStream<Directory> get backupPathStream => _backupDirectory.stream;

  @override
  void setBackupPath(String path) async {
    if (path.isEmpty) return;
    final candidate = Directory.fromUri(Uri.file(path));
    final isExists = await candidate.exists();
    if (!isExists) return;
    _storage.setString(_backupPathKey, candidate.path);
    _downloadDirectory.add(candidate);
  }
}
