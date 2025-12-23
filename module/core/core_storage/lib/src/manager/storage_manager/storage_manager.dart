import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ConverterCacheManager extends CustomCacheManager {
  ConverterCacheManager({required CustomFileService fileService})
    : super(Config('converter', fileService: fileService));
}

class TagCacheManager extends CustomCacheManager {
  TagCacheManager({required CustomFileService fileService})
    : super(Config('tag', fileService: fileService));
}

class MangaCacheManager extends CustomCacheManager {
  MangaCacheManager({required CustomFileService fileService})
    : super(Config('manga', fileService: fileService));
}

class ChapterCacheManager extends CustomCacheManager {
  ChapterCacheManager({required CustomFileService fileService})
    : super(Config('chapter', fileService: fileService));
}

class HtmlCacheManager extends CustomCacheManager {
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
