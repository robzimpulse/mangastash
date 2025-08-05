import 'package:dio/dio.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_dio/stash_dio.dart';
import 'package:stash_sqlite/stash_sqlite.dart';

class StorageManager {
  final Cache network;

  final Cache<DateTime> converter;

  StorageManager._({
    required this.network,
    required this.converter,
  });

  Interceptor get interceptor {
    return network.interceptor('/([a-z-_0-9/:.]*.(jpg|jpeg|png|gif))/i');
  }

  Future<void> clear() async {
    await Future.wait([network.clear(), converter.clear()]);
  }

  static Future<StorageManager> create() async {
    final memory = await newSqliteMemoryCacheStore();
    final persistent = await newSqliteLocalCacheStore();

    return StorageManager._(
      converter: newTieredCache(
        DefaultCacheManager(),
        await memory.cache(
          name: 'converter-cache',
          maxEntries: 100,
          evictionPolicy: const LruEvictionPolicy(),
          expiryPolicy: const TouchedExpiryPolicy(Duration(minutes: 30)),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        await persistent.cache(
          name: 'converter-storage',
          expiryPolicy: const EternalExpiryPolicy(),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        name: 'converter',
        statsEnabled: true,
      ),
      network: newTieredCache(
        DefaultCacheManager(),
        await memory.cache(
          name: 'network-cache',
          maxEntries: 100,
          evictionPolicy: const LruEvictionPolicy(),
          expiryPolicy: const TouchedExpiryPolicy(Duration(minutes: 30)),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        await persistent.cache(
          name: 'network-storage',
          expiryPolicy: const EternalExpiryPolicy(),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        name: 'network',
        statsEnabled: true,
      ),
    );
  }
}
