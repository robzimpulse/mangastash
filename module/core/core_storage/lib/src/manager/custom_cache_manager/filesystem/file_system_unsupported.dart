import 'package:file/src/interface/file.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';

import '../../../use_case/listen_download_path_use_case.dart';

class CustomFileSystem extends FileSystem {

  final String _cacheKey;
  final ListenDownloadPathUseCase _listenDownloadPathUseCase;

  CustomFileSystem(this._cacheKey, this._listenDownloadPathUseCase,);

  @override
  Future<File> createFile(String name) => throw UnimplementedError();
}