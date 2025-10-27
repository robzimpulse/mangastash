import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/dio_file_service.dart';

class ImageCacheManager extends CacheManager {
  ImageCacheManager({required DioFileService fileService})
    : super(Config('image', fileService: fileService));
}

class ConverterCacheManager extends CacheManager {
  ConverterCacheManager({required DioFileService fileService})
    : super(Config('converter', fileService: fileService));
}

class TagCacheManager extends CacheManager {
  TagCacheManager({required DioFileService fileService})
    : super(Config('tag', fileService: fileService));
}

class MangaCacheManager extends CacheManager {
  MangaCacheManager({required DioFileService fileService})
    : super(Config('manga', fileService: fileService));
}

class ChapterCacheManager extends CacheManager {
  ChapterCacheManager({required DioFileService fileService})
    : super(Config('chapter', fileService: fileService));
}

class HtmlCacheManager extends CacheManager {
  HtmlCacheManager({required DioFileService fileService})
    : super(Config('html', fileService: fileService));
}

class SearchChapterCacheManager extends CustomCacheManager {
  SearchChapterCacheManager({required DioFileService fileService})
    : super(Config('search_chapter', fileService: fileService));
}

class SearchMangaCacheManager extends CustomCacheManager {
  SearchMangaCacheManager({required DioFileService fileService})
    : super(Config('search_manga', fileService: fileService));
}
