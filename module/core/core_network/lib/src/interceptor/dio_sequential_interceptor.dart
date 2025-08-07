import 'dart:collection';

import 'package:dio/dio.dart';

class DioSequentialInterceptor extends Interceptor {
  final bool Function(RequestOptions)? shouldQueue;

  final Queue<(RequestOptions, RequestInterceptorHandler)> pending = Queue();

  bool _processing = false;

  DioSequentialInterceptor({this.shouldQueue});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (shouldQueue?.call(options) == true) {
      if (!_processing) {
        _processing = true;
        handler.next(options);
      } else {
        pending.addLast((options, handler));
      }
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (shouldQueue?.call(response.requestOptions) == true) {
      handler.next(response);
      final hashcode = response.requestOptions.hashCode;
      pending.removeWhere((e) => e.$1.hashCode == hashcode);
      _processing = false;
    } else {
      handler.next(response);
    }

    _executeNextPendingRequest();
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (shouldQueue?.call(err.requestOptions) == true) {
      handler.next(err);
      pending.removeWhere((e) => e.$1.hashCode == err.requestOptions.hashCode);
      _processing = false;
    } else {
      handler.next(err);
    }

    _executeNextPendingRequest();
  }

  void _executeNextPendingRequest() {
    if (pending.isNotEmpty) {
      final value = pending.removeFirst();
      onRequest(value.$1, value.$2);
    }
  }
}
