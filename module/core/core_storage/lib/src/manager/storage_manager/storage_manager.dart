import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../core_storage.dart';
import 'file_service/dio_file_service.dart';

class StorageManager {
  final BaseCacheManager images;

  final BaseCacheManager converter;

  final BaseCacheManager tags;

  final BaseCacheManager manga;

  final BaseCacheManager chapter;

  final CustomCacheManager searchManga;

  final CustomCacheManager searchChapter;

  StorageManager({required ValueGetter<Dio> dio})
    : images = CacheManager(Config('image', fileService: DioFileService(dio))),
      converter = CacheManager(
        Config('converter', fileService: DioFileService(dio)),
      ),
      tags = CacheManager(Config('tags', fileService: DioFileService(dio))),
      manga = CacheManager(Config('manga', fileService: DioFileService(dio))),
      chapter = CacheManager(
        Config('chapter', fileService: DioFileService(dio)),
      ),
      searchChapter = CustomCacheManager(
        Config('search_chapter', fileService: DioFileService(dio)),
      ),
      searchManga = CustomCacheManager(
        Config('search_manga', fileService: DioFileService(dio)),
      );

  Future<void> clear() async {
    await Future.wait([
      images.emptyCache(),
      converter.emptyCache(),
      tags.emptyCache(),
      manga.emptyCache(),
      chapter.emptyCache(),
      searchChapter.emptyCache(),
      searchManga.emptyCache(),
    ]);
  }

  Future<void> dispose() async {
    await Future.wait([
      images.dispose(),
      converter.dispose(),
      tags.dispose(),
      manga.dispose(),
      chapter.dispose(),
      searchChapter.dispose(),
      searchManga.dispose(),
    ]);
  }
}
