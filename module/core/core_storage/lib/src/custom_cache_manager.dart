import 'dart:async';
import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const _key = 'customCachedImageData';

  CustomCacheManager._() : super(Config(_key));

  factory CustomCacheManager.create() => CustomCacheManager._();

  final Map<String, StreamSubscription> _streams = {};

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

    final broadcast = stream.asBroadcastStream(
      onCancel: (subscription) => log(
        'Cancelling $subscription',
        name: runtimeType.toString(),
        time: DateTime.now(),
      ),
    );

    _streams[url] = broadcast
        .map((event) => event is FileInfo ? event : null)
        .listen((event) => _onFinishDownloadFile(url, event));

    return broadcast;
  }

  void _onFinishDownloadFile(String key, FileInfo? fileInfo) async {
    if (fileInfo == null) return;
    _streams[key]?.cancel();
    log(
      '[_onFinishDownloadFile] ${fileInfo.source} | ${fileInfo.originalUrl}',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );
  }
}
