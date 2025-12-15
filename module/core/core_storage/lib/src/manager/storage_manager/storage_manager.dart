import 'dart:async';

import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImageCacheManager extends CustomCacheManager {
  final ImageByteDao _imageByteDao;
  final LogBox _logBox;

  ImageCacheManager({
    required CustomFileService fileService,
    required ImageByteDao imageByteDao,
    required LogBox logBox,
  }) : _imageByteDao = imageByteDao,
       _logBox = logBox,
       super(
         Config('image', fileService: fileService, maxNrOfCacheObjects: 10),
         onDeleteFile: (object, data) async {
           logBox.log(
             '[Move] Image file to Database',
             extra: {'cache': object.toMap(setTouchedToNow: false)},
             name: 'ImageCacheManager',
           );
           await imageByteDao.add(webUrl: object.url, data: data);
         },
       );

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final controller = StreamController<FileResponse>();

    _logBox.log(
      '[Start] get file stream',
      name: runtimeType.toString(),
      extra: {'url': url},
    );

    _imageByteDao
        .search(webUrls: [url])
        .then((results) => results.firstOrNull?.byte)
        .then<void>((data) async {
          if (data != null) {
            _logBox.log(
              '[Hit] Copy image file from Database to Cache',
              name: runtimeType.toString(),
              extra: {'url': url},
            );

            controller.add(
              FileInfo(
                await putFile(url, data),
                FileSource.Cache,
                DateTime.now().add(Duration(days: 1)),
                url,
              ),
            );
          } else {
            _logBox.log(
              '[Miss] Using image file from Cache',
              name: runtimeType.toString(),
              extra: {'url': url},
            );

            await controller.addStream(
              super.getFileStream(
                url,
                key: key,
                headers: headers,
                withProgress: withProgress,
              ),
            );
          }
        })
        .onError((e, st) async {
          _logBox.log(
            '[Error] Using image file from Cache',
            name: runtimeType.toString(),
            extra: {'url': url},
            error: e,
            stackTrace: st,
          );

          await controller.addStream(
            super.getFileStream(
              url,
              key: key,
              headers: headers,
              withProgress: withProgress,
            ),
          );
        })
        .whenComplete(() {
          _logBox.log(
            '[Finish] get file stream',
            name: runtimeType.toString(),
            extra: {'url': url},
          );

          controller.close();
        });

    return controller.stream;
  }
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
