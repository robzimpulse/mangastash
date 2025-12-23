import 'package:file/src/interface/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'custom_cache_store.dart';
import 'custom_web_helper.dart';

class CustomCacheManager implements BaseCacheManager {
  late final BaseCacheManager _cache;

  late final CustomCacheStore _cacheStore;

  CustomCacheManager(Config config) {
    _cacheStore = CustomCacheStore(config);

    /// ignore: invalid_use_of_visible_for_testing_member
    _cache = CacheManager.custom(
      config,
      cacheStore: _cacheStore,
      webHelper: CustomWebHelper(_cacheStore, config.fileService),
    );
  }

  Stream<DeletedFileData> get deleteFileEvent => _cacheStore.deleteFileEvent;

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
  Future<void> emptyCache() {
    return _cache.emptyCache();
  }

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) {
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

  Future<int> getSize() => _cacheStore.getCacheSize();
}
