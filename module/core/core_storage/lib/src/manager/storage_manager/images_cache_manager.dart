import 'dart:async';

import 'package:core_analytics/core_analytics.dart';
import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImagesCacheManager extends CustomCacheManager with ImageCacheManager {
  final LogBox _logBox;
  final FileDao _fileDao;

  ImagesCacheManager({
    required CustomFileService fileService,
    required LogBox logBox,
    required FileDao fileDao,
  }) : _logBox = logBox,
       _fileDao = fileDao,
       super(
         Config('image', fileService: fileService),
         onDeleteFile: (object, data, ext) {
           logBox.log(
             '[Move] Image file to Database',
             extra: {'cache': object.toMap(setTouchedToNow: false)},
             name: 'ImageCacheManager',
           );

           fileDao.add(webUrl: object.url, data: data, extension: ext);
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

    _fileDao
        .search(webUrls: [url])
        .then<File?>((results) {
          final data = results.firstOrNull;
          if (data == null) return null;
          return _fileDao.file(data);
        })
        .then<void>((file) async {
          if (file != null && await file.exists()) {
            _logBox.log(
              '[Hit] Copy image file from Database to Cache',
              name: runtimeType.toString(),
              extra: {'url': url},
            );

            controller.add(
              FileInfo(
                file,
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
