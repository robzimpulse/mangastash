import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../use_case/listen_download_path_use_case.dart';
import 'filesystem/file_system_unsupported.dart'
    if (dart.library.html) 'filesystem/file_system_web.dart'
    if (dart.library.io) 'filesystem/file_system_io.dart' as impl;

class CustomCacheManager extends CacheManager {
  static const _key = 'customCachedImageData';

  CustomCacheManager._(ListenDownloadPathUseCase listenDownloadPathUseCase)
      : super(
          Config(
            _key,
            fileSystem: impl.CustomFileSystem(_key, listenDownloadPathUseCase),
          ),
        );

  factory CustomCacheManager.create({
    required ListenDownloadPathUseCase listenDownloadPathUseCase,
  }) {
    return CustomCacheManager._(listenDownloadPathUseCase);
  }
}
