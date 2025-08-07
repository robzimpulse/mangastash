import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dio_get_response.dart';

class DioFileService extends FileService {
  final ValueGetter<Dio> _dio;

  DioFileService(this._dio);

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return DioGetResponse(
      await _dio().get<ResponseBody>(
        url,
        options: Options(
          headers: headers ?? {},
          responseType: ResponseType.stream,
        ),
      ),
    );
  }
}
