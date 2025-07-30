import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'file_service/dio_file_service.dart';

class CustomCacheManager {
  final CacheManager images;

  final CacheManager html;

  final CacheManager utils;

  CustomCacheManager({required ValueGetter<Dio> dio})
    : images = CacheManager(Config('image', fileService: DioFileService(dio))),
      utils = CacheManager(Config('util', fileService: DioFileService(dio))),
      html = CacheManager(Config('html', fileService: DioFileService(dio)));

  Future<void> dispose() async {
    await Future.wait([images.dispose(), utils.dispose(), html.dispose()]);
  }

  Future<void> empty() async {
    await Future.wait([
      images.emptyCache(),
      utils.emptyCache(),
      html.emptyCache(),
    ]);
  }
}
