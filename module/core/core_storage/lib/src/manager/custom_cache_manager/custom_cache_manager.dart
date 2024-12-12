import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'file_service/dio_file_service.dart';

class CustomCacheManager extends CacheManager {
  static const _key = 'customCachedImageData';

  CustomCacheManager._({required Dio dio})
      : super(Config(_key, fileService: DioFileService(dio)));

  factory CustomCacheManager.create({required Dio dio}) =>
      CustomCacheManager._(dio: dio);
}
