import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:log_box/log_box.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/dio_file_service.dart';

class StorageManager {
  final BaseCacheManager images;

  final BaseCacheManager converter;

  final BaseCacheManager tags;

  final BaseCacheManager manga;

  final BaseCacheManager chapter;

  final BaseCacheManager html;

  final CustomCacheManager searchManga;

  final CustomCacheManager searchChapter;

  StorageManager({required ValueGetter<Dio> dio, required LogBox logbox})
    : images = CacheManager(Config('image', fileService: DioFileService(dio))),
      converter = CacheManager(
        Config('converter', fileService: DioFileService(dio)),
      ),
      tags = CacheManager(Config('tags', fileService: DioFileService(dio))),
      manga = CacheManager(Config('manga', fileService: DioFileService(dio))),
      chapter = CacheManager(
        Config('chapter', fileService: DioFileService(dio)),
      ),
      html = CacheManager(Config('html', fileService: DioFileService(dio))),
      searchChapter = CustomCacheManager(
        Config('search_chapter', fileService: DioFileService(dio)),
        logbox: logbox,
      ),
      searchManga = CustomCacheManager(
        Config('search_manga', fileService: DioFileService(dio)),
        logbox: logbox,
      );

  Future<void> clear() async {
    await Future.wait([
      images.emptyCache(),
      converter.emptyCache(),
      tags.emptyCache(),
      manga.emptyCache(),
      chapter.emptyCache(),
      html.emptyCache(),
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
      html.dispose(),
      searchChapter.dispose(),
      searchManga.dispose(),
    ]);
  }
}
