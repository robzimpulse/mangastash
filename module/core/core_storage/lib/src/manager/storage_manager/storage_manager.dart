import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stash/stash_api.dart' hide CacheManager;
import 'package:stash_hive/stash_hive.dart';

import 'file_service/dio_file_service.dart';

class StorageManager {
  final BaseCacheManager images;

  final Cache<DateTime> converter;

  StorageManager._({required this.images, required this.converter}) {
    converter.on<CacheEntryCreatedEvent<DateTime>>().listen(
      (e) => print('Created: ${e.entry.key}'),
    );
    converter.on<CacheEntryUpdatedEvent<DateTime>>().listen(
      (e) => print('Updated: ${e.newEntry.key}'),
    );
    converter.on<CacheEntryRemovedEvent<DateTime>>().listen(
      (e) => print('Removed: ${e.entry.key}'),
    );
    converter.on<CacheEntryExpiredEvent<DateTime>>().listen(
      (e) => print('Expired: ${e.entry.key}'),
    );
    converter.on<CacheEntryEvictedEvent<DateTime>>().listen(
      (e) => print('Evicted: ${e.entry.key}'),
    );
  }

  Future<void> clear() async {
    await Future.wait([images.emptyCache(), converter.clear()]);
  }

  static Future<StorageManager> create({required ValueGetter<Dio> dio}) async {
    final memory = await newHiveLazyCacheStore(
      path: kIsWeb ? null : (await getApplicationDocumentsDirectory()).path,
    );

    return StorageManager._(
      converter: newTieredCache(
        null,
        await memory.cache(
          name: 'converter-cache',
          maxEntries: 100,
          evictionPolicy: const LruEvictionPolicy(),
          expiryPolicy: const TouchedExpiryPolicy(Duration(minutes: 30)),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        await memory.cache(
          name: 'converter-storage',
          expiryPolicy: const EternalExpiryPolicy(),
          eventListenerMode: EventListenerMode.synchronous,
        ),
        name: 'converter',
        statsEnabled: true,
      ),
      images: CacheManager(Config('image', fileService: DioFileService(dio))),
    );
  }
}
