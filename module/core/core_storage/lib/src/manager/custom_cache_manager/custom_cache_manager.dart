import 'package:file/src/interface/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:log_box/log_box.dart';

import 'custom_cache_store.dart';

class CustomCacheManager implements BaseCacheManager {
  late final BaseCacheManager _cache;

  late final CustomCacheStore _cacheStore;

  late final LogBox _logBox;

  CustomCacheManager(Config config, {required LogBox logBox}) {
    _cacheStore = CustomCacheStore(config);
    _cache = CacheManager.custom(config, cacheStore: _cacheStore);
    _logBox = logBox;
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
    return _cache.downloadFile(
      url,
      key: key,
      authHeaders: authHeaders,
      force: force,
    );
  }

  @override
  Future<void> emptyCache() => _cache.emptyCache();

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) {
    _logBox.log(
      'Get: $key',
      name: '${runtimeType.toString()} - ${_cacheStore.storeKey}',
    );
    return _cache.getFileFromCache(key, ignoreMemCache: ignoreMemCache);
  }

  @override
  Future<FileInfo?> getFileFromMemory(String key) {
    return _cache.getFileFromMemory(key);
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
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
      'Put: $key',
      name: '${runtimeType.toString()} - ${_cacheStore.storeKey}',
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
      'Remove: $key',
      name: '${runtimeType.toString()} - ${_cacheStore.storeKey}',
    );
    return _cache.removeFile(key);
  }

  @override
  Stream<FileInfo> getFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) {
    return _cache.getFile(url, key: key ?? url, headers: headers ?? {});
  }
}
