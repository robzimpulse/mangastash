import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImageCacheManager extends CustomCacheManager {
  ImageCacheManager({required CustomFileService fileService})
    : super(Config('image', fileService: fileService));
}

class ConverterCacheManager extends CacheManager {
  ConverterCacheManager({required CustomFileService fileService})
    : super(Config('converter', fileService: fileService));
}

class HtmlCacheManager extends CacheManager {
  HtmlCacheManager({required CustomFileService fileService})
    : super(Config('html', fileService: fileService));
}

class SearchChapterCacheManager extends CustomCacheManager {
  SearchChapterCacheManager({required CustomFileService fileService})
    : super(Config('search_chapter', fileService: fileService));
}

class SearchMangaCacheManager extends CustomCacheManager {
  SearchMangaCacheManager({required CustomFileService fileService})
    : super(Config('search_manga', fileService: fileService));
}
