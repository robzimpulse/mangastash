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
    final root = Directory.fromUri(Uri.file('/storage/emulated/0'));
    final rootDirectory = (await root.exists() && Platform.isAndroid)
        ? root
        : await getApplicationDocumentsDirectory();

    final path = storage.getString(_key);
    final candidate = path != null ? Directory.fromUri(Uri.file(path)) : null;
    final downloadDirectory = candidate != null
        ? await candidate.exists()
            ? candidate
            : rootDirectory
        : rootDirectory;

    return PathManager._(
      rootDirectory: rootDirectory,
      downloadDirectory: downloadDirectory,
      storage: storage,
    );
  }

  @override
  void setDownloadPath(String path) async {
    if (path.isEmpty) return;
    final candidate = Directory.fromUri(Uri.file(path));
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
