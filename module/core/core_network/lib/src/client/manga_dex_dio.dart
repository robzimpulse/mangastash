import 'package:alice_lightweight/alice.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

import '../adapter/dio_adapter.dart'
    if (dart.library.io) '../adapter/dio_adapter_mobile.dart'
    if (dart.library.js) '../adapter/dio_adapter_web.dart';
import '../interceptor/header_interceptor.dart';

class MangaDexDio extends DioForNative {
  final HeaderInterceptor _headerInterceptor = HeaderInterceptor();

  MangaDexDio({
    required Alice alice,
    BaseOptions? options,
  }) : super(options) {
    this.options.baseUrl = 'https://api.mangadex.org';

    interceptors
      ..add(alice.getDioInterceptor())
      ..add(_headerInterceptor);

    httpClientAdapter = getAdapter();
  }
}
