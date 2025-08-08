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

  final Cache<List<Map<String, dynamic>>> tags;

  final Cache<Map<String, dynamic>> manga;

  StorageManager._({
    required this.images,
    required this.converter,
    required this.tags,
    required this.manga,
  });

  Future<void> clear() async {
    await Future.wait([
      images.emptyCache(),
      converter.clear(),
      tags.clear(),
      manga.clear(),
    ]);
  }

  Future<void> dispose() async {
    await Future.wait([
      images.dispose(),
      converter.close(),
      tags.close(),
      manga.close(),
    ]);
  }

  static Future<StorageManager> create({required ValueGetter<Dio> dio}) async {
    final memory = await newHiveLazyCacheStore(
      path: kIsWeb ? null : (await getApplicationDocumentsDirectory()).path,
    );

    return StorageManager._(
      converter: await memory.cache(
        name: 'converter-cache',
        expiryPolicy: const EternalExpiryPolicy(),
        eventListenerMode: EventListenerMode.synchronous,
      ),
      tags: await memory.cache(
        name: 'tags-cache',
        evictionPolicy: const LruEvictionPolicy(),
        expiryPolicy: const TouchedExpiryPolicy(Duration(minutes: 30)),
        eventListenerMode: EventListenerMode.synchronous,
      ),
      manga: await memory.cache(
        name: 'manga-cache',
        evictionPolicy: const LruEvictionPolicy(),
        expiryPolicy: const TouchedExpiryPolicy(Duration(minutes: 30)),
        eventListenerMode: EventListenerMode.synchronous,
      ),
      images: CacheManager(Config('image', fileService: DioFileService(dio))),
    );
  }
}
