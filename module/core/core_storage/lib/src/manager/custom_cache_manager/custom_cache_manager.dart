import 'package:file/src/interface/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:log_box/log_box.dart';

import 'custom_cache_store.dart';

class CustomCacheManager implements BaseCacheManager {
  late final BaseCacheManager _cache;

  late final CustomCacheStore _cacheStore;

  late final LogBox _logBox;

  CustomCacheManager(Config config, {required LogBox logBox})
    : _logBox = logBox {
    _cacheStore = CustomCacheStore(config);
    _cache = CacheManager.custom(config, cacheStore: _cacheStore);
  }

  Future<Set<String>> get keys => _cacheStore.keys;

  @override
  Future<void> dispose() async {
    await Future.wait([_cache.dispose(), _cacheStore.dispose()]);
  }

  @override
  Future<FileInfo> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
  }) {
    _logBox.log(
      'Download File',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.downloadFile(
      url,
      key: key,
      authHeaders: authHeaders,
      force: force,
    );
  }

  @override
  Future<void> emptyCache() {
    _logBox.log('Empty Cache', name: '$runtimeType - ${_cacheStore.storeKey}');
    return _cache.emptyCache();
  }

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) {
    _logBox.log(
      'Get File from Cache',
      extra: {'key': key},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.getFileFromCache(key, ignoreMemCache: ignoreMemCache);
  }

  @override
  Future<FileInfo?> getFileFromMemory(String key) {
    _logBox.log(
      'Get File From Memory',
      extra: {'key': key},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.getFileFromMemory(key);
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    _logBox.log(
      'Get File Stream',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.getFileStream(
      url,
      key: key,
      headers: headers,
      withProgress: withProgress,
    );
  }

  @override
  Future<File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) {
    _logBox.log(
      'Get Single File',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.getSingleFile(url, key: key ?? url, headers: headers ?? {});
  }

  @override
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) {
    _logBox.log(
      'Put File',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.putFile(
      url,
      fileBytes,
      key: key,
      eTag: eTag,
      maxAge: maxAge,
      fileExtension: fileExtension,
    );
  }

  @override
  Future<File> putFileStream(
    String url,
    Stream<List<int>> source, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) {
    _logBox.log(
      'Put File stream',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.putFileStream(
      url,
      source,
      key: key,
      eTag: eTag,
      maxAge: maxAge,
      fileExtension: fileExtension,
    );
  }

  @override
  Future<void> removeFile(String key) {
    _logBox.log(
      'Remove File',
      extra: {'key': key},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.removeFile(key);
  }

  @override
  Stream<FileInfo> getFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) {
    _logBox.log(
      'Get File',
      extra: {'key': key, 'url': url},
      name: '$runtimeType - ${_cacheStore.storeKey}',
    );
    return _cache.getFile(url, key: key ?? url, headers: headers ?? {});
  }
}
