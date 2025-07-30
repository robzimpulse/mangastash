import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'file_service/dio_file_service.dart';

class CustomCacheManager extends CacheManager {
  CustomCacheManager({required ValueGetter<Dio> dio})
    : super(Config('cache', fileService: DioFileService(dio)));
}
