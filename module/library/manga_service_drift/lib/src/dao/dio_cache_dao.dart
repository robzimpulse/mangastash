import 'package:drift/drift.dart';
import 'package:http_cache_core/http_cache_core.dart';

import '../database/database.dart';
import '../tables/dio_cache_tables.dart';

part 'dio_cache_dao.g.dart';

@DriftAccessor(
  tables: [
    DioCacheTables,
  ],
)
class DioCacheDao extends DatabaseAccessor<AppDatabase> with _$DioCacheDaoMixin {
  DioCacheDao(AppDatabase db) : super(db);

  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final query = delete(dioCacheTables)
      ..where(
            (t) {
          var expr = t.priority.isSmallerOrEqualValue(priorityOrBelow.index);
          if (staleOnly) {
            expr =
            expr & t.maxStale.isSmallerOrEqualValue(DateTime.now().toUtc());
          }
          return expr;
        },
      );

    await query.go();
  }

  Future<void> deleteKey(String key, {bool staleOnly = false}) async {
    final query = delete(dioCacheTables)
      ..where((t) {
        final expr = t.cacheKey.equals(key);

        return staleOnly
            ? expr & t.maxStale.isSmallerOrEqualValue(DateTime.now().toUtc())
            : expr;
      });

    await query.go();
  }

  Future<bool> exists(String key) async {
    final query = select(dioCacheTables)
      ..where((t) => t.cacheKey.equals(key))
      ..limit(1);
    return (await query.getSingleOrNull()) != null;
  }

  Future<CacheResponse?> get(String key) async {
    // Get record
    final query = select(dioCacheTables)
      ..where((t) => t.cacheKey.equals(key))
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result == null) return Future.value();

    return _mapDataToResponse(result);
  }

  Future<void> set(CacheResponse response) async {
    final checkedContent = response.content;
    final checkedHeaders = response.headers;

    await into(dioCacheTables).insert(
      DioCacheDrift(
        date: response.date,
        cacheControl: response.cacheControl.toHeader(),
        content: (checkedContent != null)
            ? Uint8List.fromList(checkedContent)
            : null,
        eTag: response.eTag,
        expires: response.expires,
        headers: (checkedHeaders != null)
            ? Uint8List.fromList(checkedHeaders)
            : null,
        cacheKey: response.key,
        lastModified: response.lastModified,
        maxStale: response.maxStale,
        priority: response.priority.index,
        requestDate: response.requestDate,
        responseDate: response.responseDate,
        url: response.url,
        statusCode: response.statusCode,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  CacheResponse _mapDataToResponse(DioCacheDrift data) {
    return CacheResponse(
      cacheControl: CacheControl.fromString(data.cacheControl),
      content: data.content,
      date: data.date,
      eTag: data.eTag,
      expires: data.expires,
      headers: data.headers,
      key: data.cacheKey,
      lastModified: data.lastModified,
      maxStale: data.maxStale,
      priority: CachePriority.values[data.priority],
      requestDate: data.requestDate ??
          data.responseDate.subtract(const Duration(milliseconds: 150)),
      responseDate: data.responseDate,
      url: data.url,
      statusCode: data.statusCode ?? 304,
    );
  }

  Future<void> deleteKeys(List<String> keys) async {
    final query = delete(dioCacheTables)..where((t) => t.cacheKey.isIn(keys));
    await query.go();
  }

  Future<List<CacheResponse>> getMany(List<String> keys) {
    final query = select(dioCacheTables)
      ..where((t) => t.cacheKey.isIn(keys))
      ..orderBy([(t) => OrderingTerm(expression: t.date)]);

    return query.get().then((e) => e.map(_mapDataToResponse).toList());
  }
}