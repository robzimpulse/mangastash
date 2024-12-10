import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../use_case/listen_download_path_use_case.dart';

class CustomFileSystem extends FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;
  final ListenDownloadPathUseCase _listenDownloadPathUseCase;

  CustomFileSystem(
    this._cacheKey,
    ListenDownloadPathUseCase listenDownloadPathUseCase,
  )   : _fileDir = _createDirectory(_cacheKey, listenDownloadPathUseCase),
        _listenDownloadPathUseCase = listenDownloadPathUseCase;

  static Future<Directory> _createDirectory(
    String key,
    ListenDownloadPathUseCase listenDownloadPathUseCase,
  ) async {
    final rootDir = listenDownloadPathUseCase.downloadPathStream.valueOrNull;
    final baseDir = rootDir ?? await getTemporaryDirectory();
    final path = p.join(baseDir.path, key);

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await _createDirectory(_cacheKey, _listenDownloadPathUseCase);
    }
    return directory.childFile(name);
  }
}
