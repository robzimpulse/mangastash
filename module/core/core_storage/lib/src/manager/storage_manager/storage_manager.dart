import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImageCacheManager extends CustomCacheManager {
  ImageCacheManager({
    required CustomFileService fileService,
    required ImageByteDao imageByteDao,
    required LogBox logBox,
  }) : super(
         Config('image', fileService: fileService, maxNrOfCacheObjects: 10),
         onDeleteFile: (object, data) async {
           logBox.log(
             'Moving image file to Database',
             name: 'ImageCacheManager',
           );
           await imageByteDao.add(webUrl: object.url, data: data);
         },
       );
}

class ConverterCacheManager extends CacheManager {
  ConverterCacheManager({required CustomFileService fileService})
    : super(Config('converter', fileService: fileService));
}

class TagCacheManager extends CacheManager {
  TagCacheManager({required CustomFileService fileService})
    : super(Config('tag', fileService: fileService));
}

class MangaCacheManager extends CacheManager {
  MangaCacheManager({required CustomFileService fileService})
    : super(Config('manga', fileService: fileService));
}

class ChapterCacheManager extends CacheManager {
  ChapterCacheManager({required CustomFileService fileService})
    : super(Config('chapter', fileService: fileService));
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
