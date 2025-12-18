import 'dart:async';

import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImagesCacheManager extends CustomCacheManager with ImageCacheManager {
  final FileDao _fileDao;

  ImagesCacheManager({
    required CustomFileService fileService,
    required FileDao fileDao,
  }) : _fileDao = fileDao,
       super(
         Config('image', fileService: fileService),
         onDeleteFile: (object, data, ext) {
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

    _fileDao
        .search(webUrls: [url])
        .then((results) => _fileDao.file(results.first))
        .then((file) {
          controller.add(
            FileInfo(
              file,
              FileSource.Cache,
              DateTime.now().add(Duration(days: 1)),
              url,
            ),
          );
        })
        .onError((e, st) async {
          await controller.addStream(
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
  }) {
    return _fileDao
        .search(webUrls: [url])
        .then((results) => _fileDao.file(results.first))
        .onError(
          (_, __) => super.getSingleFile(url, key: key, headers: headers),
        );
  }



}
