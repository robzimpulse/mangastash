import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor();

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    try {
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
    } finally {
      super.onRequest(options, handler);
    }
  }
}
