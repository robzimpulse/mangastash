import 'dart:async';

import 'package:core_analytics/core_analytics.dart';
import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImagesCacheManager extends CustomCacheManager with ImageCacheManager {
  final FileDao _fileDao;
  final LogBox _logbox;

  ImagesCacheManager({
    required CustomFileService fileService,
    required FileDao fileDao,
    required LogBox logBox,
  }) : _fileDao = fileDao,
       _logbox = logBox,
       super(Config('image', fileService: fileService));

  Future<File> _getFromDatabase({required String url}) {
    return _fileDao
        .search(webUrls: [url])
        .then((results) => _fileDao.file(results.first));
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final controller = StreamController<FileResponse>();

    _getFromDatabase(url: url)
        .then(
          (file) => controller.add(
            FileInfo(
              file,
              FileSource.Cache,
              DateTime.now().add(Duration(days: 1)),
              url,
            ),
          ),
        )
        .then(
          (_) => _logbox.log(
            'Using file from database',
            name: runtimeType.toString(),
            extra: {
              'url': url,
              'key': key,
              'headers': headers,
              'withProgress': withProgress,
            },
          ),
        )
        .onError((e, st) {
          _logbox.log(
            'Using file from cache',
            name: runtimeType.toString(),
            extra: {
              'url': url,
              'key': key,
              'headers': headers,
              'withProgress': withProgress,
            },
            error: e,
            stackTrace: st,
          );

          return controller.addStream(
            super.getFileStream(
              url,
              key: key,
              headers: headers,
              withProgress: withProgress,
            ),
          );
        })
        .whenComplete(() => controller.close());

    return controller.stream;
  }

  @override
  Future<File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) async {
    return _getFromDatabase(url: url)
        .then((file) {
          _logbox.log(
            'Using file from database',
            name: runtimeType.toString(),
            extra: {'url': url, 'key': key, 'headers': headers},
          );
          return file;
        })
        .onError((e, st) {
          _logbox.log(
            'Using file from cache',
            name: runtimeType.toString(),
            extra: {'url': url, 'key': key, 'headers': headers},
            error: e,
            stackTrace: st,
          );

          return super.getSingleFile(url, key: key, headers: headers);
        });
  }
}
