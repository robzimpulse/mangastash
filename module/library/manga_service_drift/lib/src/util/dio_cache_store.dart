import 'package:drift/drift.dart';
import 'package:http_cache_core/http_cache_core.dart';

import '../dao/dio_cache_dao.dart';
import '../database/database.dart';

class DioCacheStore extends CacheStore {
  final DioCacheDao _dioCacheDao;

  DioCacheStore({required AppDatabase db}) : _dioCacheDao = DioCacheDao(db) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    return _dioCacheDao.clean(
      priorityOrBelow: priorityOrBelow,
      staleOnly: staleOnly,
    );
  }

  @override
  Future<void> close() => Future.value();

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    return _dioCacheDao.deleteKey(key, staleOnly: staleOnly);
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) {
    return _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResult: _dioCacheDao.deleteKeys,
    );
  }

  @override
  Future<bool> exists(String key) {
    return _dioCacheDao.exists(key);
  }

  @override
  Future<CacheResponse?> get(String key) {
    return _dioCacheDao.get(key);
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    await _getFromPath(
      pathPattern,
      queryParams: queryParams,
      onResult: (keys) async => responses.addAll(
        await _dioCacheDao.getMany(keys),
      ),
    );

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) {
    return _dioCacheDao.set(response);
  }

  Future<void> _getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
    required Future<void> Function(List<String>) onResult,
  }) async {
    final cache = _dioCacheDao.dioCacheTables;

    final matchesPath = cache.url.regexp(
      pathPattern.pattern,
      multiLine: pathPattern.isMultiLine,
      caseSensitive: pathPattern.isCaseSensitive,
      unicode: pathPattern.isUnicode,
      dotAll: pathPattern.isDotAll,
    );

    final results = await (_dioCacheDao.selectOnly(cache)
          ..where(matchesPath)
          ..addColumns([cache.cacheKey, cache.url]))
        .map(
          (result) => MapEntry(
            result.read(cache.cacheKey)!,
            result.read(cache.url)!,
          ),
        )
        .get();

    results.removeWhere(
      (e) => !pathExists(e.value, pathPattern, queryParams: queryParams),
    );

    await onResult(results.map((e) => e.key).toList());
  }
}
