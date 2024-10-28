import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../storage/shared_preferences_storage.dart';
import '../use_case/get_root_path_use_case.dart';
import '../use_case/listen_download_path_use_case.dart';
import '../use_case/set_download_path_use_case.dart';

class PathManager
    implements
        ListenDownloadPathUseCase,
        SetDownloadPathUseCase,
        GetRootPathUseCase {
  final Directory _rootDirectory;

  final BehaviorSubject<Directory> _downloadDirectory;

  final SharedPreferencesStorage _storage;

  static const _key = 'download_path';

  PathManager._({
    required Directory rootDirectory,
    required Directory downloadDirectory,
    required SharedPreferencesStorage storage,
  })  : _downloadDirectory = BehaviorSubject.seeded(downloadDirectory),
        _storage = storage,
        _rootDirectory = rootDirectory;

  static Future<PathManager> create({
    required SharedPreferencesStorage storage,
  }) async {
    Directory? downloadDirectory;
    final path = storage.getString(_key);
    final rootDirectory = await getApplicationDocumentsDirectory();
    if (path != null && path.isNotEmpty) {
      final candidate = Directory.fromUri(Uri.directory(path));
      downloadDirectory = await candidate.exists() ? candidate : rootDirectory;
    }
    return PathManager._(
      rootDirectory: rootDirectory,
      downloadDirectory: downloadDirectory ?? rootDirectory,
      storage: storage,
    );
  }

  @override
  void setDownloadPath(String path) async {
    if (path.isEmpty) return;
    final candidate = Directory.fromUri(Uri.directory(path));
    final isExists = await candidate.exists();
    if (!isExists) return;
    _storage.setString(_key, candidate.path);
    _downloadDirectory.add(candidate);
  }

  @override
  ValueStream<Directory> get downloadPathStream => _downloadDirectory.stream;

  @override
  Directory get rootPath => _rootDirectory;
}
