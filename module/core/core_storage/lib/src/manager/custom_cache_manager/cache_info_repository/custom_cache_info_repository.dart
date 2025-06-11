import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

class CustomCacheInfoRepository implements CacheInfoRepository {
  final ValueGetter<CacheDao> _dao;

  CustomCacheInfoRepository({required ValueGetter<CacheDao> dao}) : _dao = dao;

  CacheObject _convertToObject(CacheDrift value) {
    return CacheObject(
      value.url,
      key: value.key,
      relativePath: value.relativePath,
      validTill: value.validTill,
      eTag: value.eTag,
      id: value.id,
      length: value.length,
      touched: value.touched,
    );
  }

  CacheTablesCompanion _convertToCompanion(CacheObject value) {
    return CacheTablesCompanion(
      url: Value(value.url),
      key: Value(value.key),
      relativePath: Value(value.relativePath),
      validTill: Value(value.validTill),
      eTag: Value.absentIfNull(value.eTag),
      id: Value.absentIfNull(value.id),
      length: Value.absentIfNull(value.length),
      touched: Value.absentIfNull(value.touched),
    );
  }

  @override
  Future<bool> open() => Future.value(true);

  @override
  Future<bool> close() => Future.value(true);

  @override
  Future<bool> exists() => Future.value(true);

  @override
  Future<int> delete(int id) async {
    final results = await _dao().remove(ids: [id]);
    return results.length;
  }

  @override
  Future<int> deleteAll(Iterable<int> ids) async {
    final results = await _dao().remove(ids: [...ids]);
    return results.length;
  }

  @override
  Future<CacheObject?> get(String key) async {
    final result = await _dao().search(key: key);
    final data = result.firstOrNull;
    if (data == null) return null;
    return _convertToObject(data);
  }

  @override
  Future<List<CacheObject>> getAllObjects() async{
    final results = await _dao().all;
    return [...results.map((d) => _convertToObject(d))];
  }

  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) async {
    final data = await _dao().search(
      maxAge: const Duration(days: 1),
      limit: 100,
      offset: capacity,
    );
    return [...data.map((d) => _convertToObject(d))];
  }

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) async {
    final data = await _dao().search(maxAge: maxAge, limit: 100);
    return [...data.map((d) => _convertToObject(d))];
  }

  @override
  Future<CacheObject> insert(
    CacheObject cacheObject, {
    bool setTouchedToNow = true,
  }) async {
    final data = await _dao().add(
      value: _convertToCompanion(cacheObject).copyWith(
        touched: setTouchedToNow ? Value(DateTime.timestamp()) : null,
      ),
    );
    return _convertToObject(data);
  }

  @override
  Future<int> update(
    CacheObject cacheObject, {
    bool setTouchedToNow = true,
  }) async {
    final results = await _dao().modify(
      value: _convertToCompanion(cacheObject).copyWith(
        touched: setTouchedToNow ? Value(DateTime.timestamp()) : null,
      ),
    );
    return results.length;
  }

  @override
  Future updateOrInsert(CacheObject cacheObject) {
    return cacheObject.id == null ? insert(cacheObject) : update(cacheObject);
  }

  @override
  Future<void> deleteDataFile() async {
    await _dao().remove(ids: [...(await _dao().all).map((e) => e.id)]);
  }
}
