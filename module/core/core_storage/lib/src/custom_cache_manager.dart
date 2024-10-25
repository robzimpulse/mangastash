import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const _key = 'customCachedImageData';

  CustomCacheManager._() : super(Config(_key));

  factory CustomCacheManager.create() => CustomCacheManager._();

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    final file = await super.getFileFromCache(
      key,
      ignoreMemCache: ignoreMemCache,
    );

    log(
      '[getFileFromCache] ${file?.source} | ${file?.originalUrl}',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );

    return file;
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final stream = super.getFileStream(
      url,
      key: key,
      headers: headers,
      withProgress: withProgress,
    );

    final broadcast = stream.asBroadcastStream();

    broadcast.listen((event) {
      if (event is FileInfo) {
        log(
          // TODO: close this stream after get image
          '[getFileStream] ${event.source} | ${event.originalUrl}',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
    });

    return broadcast;
  }
}
