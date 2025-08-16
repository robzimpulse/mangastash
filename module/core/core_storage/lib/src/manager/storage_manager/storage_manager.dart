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

  StorageManager({required ValueGetter<Dio> dio, required LogBox logBox})
    : images = CustomCacheManager(
        Config('image', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      converter = CustomCacheManager(
        Config('converter', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      tags = CustomCacheManager(
        Config('tags', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      manga = CustomCacheManager(
        Config('manga', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      chapter = CustomCacheManager(
        Config('chapter', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      html = CustomCacheManager(
        Config('html', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      searchChapter = CustomCacheManager(
        Config('search_chapter', fileService: DioFileService(dio)),
        logBox: logBox,
      ),
      searchManga = CustomCacheManager(
        Config('search_manga', fileService: DioFileService(dio)),
        logBox: logBox,
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
