import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../storage_manager/file_service/dio_file_service.dart';
import 'typed_cache_store.dart';

class TypedCacheManager<T> {
  late final BaseCacheManager _cache;

  late final TypedCacheStore _cacheStore;

  late final Uint8List Function(T) _encoder;

  late final T Function(Uint8List) _decoder;

  TypedCacheManager({
    required ValueGetter<Dio> dio,
    required Uint8List Function(T) encoder,
    required T Function(Uint8List) decoder,
  }) {
    final config = Config(
      T.runtimeType.toString(),
      fileService: DioFileService(dio),
    );
    _cacheStore = TypedCacheStore(config);
    _cache = CacheManager.custom(config, cacheStore: _cacheStore);
    _encoder = encoder;
    _decoder = decoder;
  }

  Future<void> put(String key, T data) async {
    await _cache.putFile(key, key: key, _encoder.call(data));
  }

  Future<T?> get(String key) async {
    final file = await _cache.getFileFromCache(key);
    final data = await file?.file.readAsBytes();
    if (data == null) return null;
    return _decoder.call(data);
  }

  Future<Set<String>> get keys => _cacheStore.keys;
}
