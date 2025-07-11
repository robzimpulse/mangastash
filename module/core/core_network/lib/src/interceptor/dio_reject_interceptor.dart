import 'package:dio/dio.dart';

class DioRejectInterceptor extends Interceptor {
  DioRejectInterceptor({this.rejector});

  final DioException? Function(RequestOptions options)? rejector;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final error = rejector?.call(options);
    error != null ? handler.reject(error) : super.onRequest(options, handler);
  }
}