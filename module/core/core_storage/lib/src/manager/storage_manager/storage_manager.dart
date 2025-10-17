import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

  StorageManager({required DioFileService fileService})
    : images = CustomCacheManager(Config('image', fileService: fileService)),
      converter = CustomCacheManager(
        Config('converter', fileService: fileService),
      ),
      tags = CustomCacheManager(Config('tags', fileService: fileService)),
      manga = CustomCacheManager(Config('manga', fileService: fileService)),
      chapter = CustomCacheManager(Config('chapter', fileService: fileService)),
      html = CustomCacheManager(Config('html', fileService: fileService)),
      searchChapter = CustomCacheManager(
        Config('search_chapter', fileService: fileService),
      ),
      searchManga = CustomCacheManager(
        Config('search_manga', fileService: fileService),
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
