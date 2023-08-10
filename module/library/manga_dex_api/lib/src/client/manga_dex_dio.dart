import 'package:alice_lightweight/core/alice_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

import '../adapter/dio_adapter.dart'
    if (dart.library.io) '../adapter/dio_adapter_mobile.dart'
    if (dart.library.js) '../adapter/dio_adapter_web.dart';
import '../interceptor/header_interceptor.dart';

class MangaDexDio extends DioForNative {
  late final AliceDioInterceptor _aliceDioInterceptor;
  late final HeaderInterceptor _headerInterceptor;

  MangaDexDio({
    required AliceDioInterceptor aliceDioInterceptor,
    required HeaderInterceptor headerInterceptor,
    BaseOptions? options,
  }) : super(options) {
    _aliceDioInterceptor = aliceDioInterceptor;
    _headerInterceptor = headerInterceptor;

    _configureClient();
    _configureOptions();
    _configureInterceptors();
  }

  void _configureOptions() {
    options.baseUrl = 'https://api.mangadex.org';
  }

  void _configureInterceptors() {
    interceptors
      ..add(_aliceDioInterceptor)
      ..add(_headerInterceptor);
  }

  void _configureClient() {
    httpClientAdapter = getAdapter();
  }
}
