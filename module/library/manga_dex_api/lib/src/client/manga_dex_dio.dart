import 'package:alice_lightweight/core/alice_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';

class MangaDexDio extends DioForNative {
  late final AliceDioInterceptor _aliceDioInterceptor;

  MangaDexDio({
    required AliceDioInterceptor aliceDioInterceptor,
    BaseOptions? options,
  })  : super(options) {

    _aliceDioInterceptor = aliceDioInterceptor;

    _configureProxy();
    _configureOptions();
    _configureInterceptors();
  }

  void _configureOptions() {
    options.baseUrl = 'api.mangadex.org';
  }

  void _configureInterceptors() {
    interceptors.add(_aliceDioInterceptor);
  }

  void _configureProxy() {
    if (!kDebugMode) return;
  }
}
