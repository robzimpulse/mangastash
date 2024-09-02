import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

import 'adapter/dio_adapter.dart'
    if (dart.library.io) 'adapter/dio_adapter_mobile.dart'
    if (dart.library.js) 'adapter/dio_adapter_web.dart';

class MangaDexDio extends DioForNative {
  final List<Interceptor> _customInterceptors;

  MangaDexDio({
    BaseOptions? options,
    List<Interceptor> interceptors = const [],
  })  : _customInterceptors = interceptors,
        super(options) {
    this.options.baseUrl = 'https://api.mangadex.org';
    this.options.headers['Content-Type'] = 'application/json';
    this.options.headers['Accept'] = 'application/json';
    this.interceptors.addAll(_customInterceptors);
    httpClientAdapter = getAdapter();
  }
}
