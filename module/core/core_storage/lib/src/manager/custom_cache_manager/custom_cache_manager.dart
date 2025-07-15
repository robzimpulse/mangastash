import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import 'cache_info_repository/custom_cache_info_repository.dart';
import 'file_service/dio_file_service.dart';

class CustomCacheManager extends CacheManager {
  CustomCacheManager({
    required ValueGetter<Dio> dio,
    required ValueGetter<CacheDao> dao,
  }) : super(
          Config(
            'cache',
            fileService: DioFileService(dio),
            repo: CustomCacheInfoRepository(dao: dao),
          ),
        );
}
