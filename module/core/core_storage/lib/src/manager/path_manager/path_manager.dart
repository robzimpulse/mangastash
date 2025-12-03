import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import '../../use_case/get_root_path_use_case.dart';
import '../../use_case/listen_backup_path_use_case.dart';
import '../../use_case/listen_download_path_use_case.dart';
import '../../use_case/set_backup_path_use_case.dart';
import '../../use_case/set_download_path_use_case.dart';

class PathManager
    implements
        ListenDownloadPathUseCase,
        SetDownloadPathUseCase,
        ListenBackupPathUseCase,
        SetBackupPathUseCase,
        GetRootPathUseCase {
  final Directory? _rootDirectory;
  final BehaviorSubject<Directory?> _downloadDirectory;
  final BehaviorSubject<Directory?> _backupDirectory;

  final SharedPreferencesAsync _storage;

  static const _downloadPathKey = 'download_path';
  static const _backupPathKey = 'backup_path';

  PathManager._({
    Directory? rootDirectory,
    Directory? backupDirectory,
    Directory? downloadDirectory,
    required SharedPreferencesAsync storage,
  }) : _downloadDirectory = BehaviorSubject.seeded(downloadDirectory),
       _backupDirectory = BehaviorSubject.seeded(backupDirectory),
       _rootDirectory = rootDirectory,
       _storage = storage;

  static Future<PathManager> create({
    required SharedPreferencesAsync storage,
  }) async {
    final backupPath = await storage
        .getString(_backupPathKey)
        .then((e) => e != null ? Directory.fromUri(Uri.file(e)) : null);
    final isBackupPathExists = await backupPath?.exists();

    return PathManager._(
      rootDirectory:
          kIsWeb
              ? null
              : (defaultTargetPlatform == TargetPlatform.android)
              ? Directory.fromUri(Uri.file('/storage/emulated/0'))
              : await getApplicationDocumentsDirectory(),
      backupDirectory: isBackupPathExists == true ? backupPath : null,
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
  void setBackupPath(String path) async {
    if (path.isEmpty) return;
    final candidate = Directory.fromUri(Uri.file(path));
    final isExists = await candidate.exists();
    if (!isExists) return;
    _storage.setString(_backupPathKey, candidate.path);
    _backupDirectory.add(candidate);
  }

  @override
  ValueStream<Directory?> get downloadPathStream => _downloadDirectory.stream;

  @override
  ValueStream<Directory?> get backupPathStream => _backupDirectory.stream;

  @override
  Directory? get rootPath => _rootDirectory;
}
