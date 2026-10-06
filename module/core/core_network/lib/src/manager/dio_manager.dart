import 'package:core_analytics/core_analytics.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:universal_io/io.dart';

import '../interceptor/dio_reject_interceptor.dart';
import '../interceptor/dio_throttler_interceptor.dart';
import '../mixin/user_agent_mixin.dart';
import 'user_agent_manager.dart';

class DioManager {
  /// In dio 5.11.1, receiveTimeout bounds the wait for the response HEADERS
  /// (time-to-first-byte, `request.close()` in `io_adapter.dart`) and then
  /// each gap between body chunks. A server that takes >30s to first byte —
  /// or stalls >30s mid-body — fails with `DioException.receiveTimeout` and
  /// `CustomFileService` falls back to the heavyweight headless-webview path.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static Dio create({required LogBox log, List<Duration> retryDelays = const [Duration(milliseconds: 500), Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)], UserAgentManager? userAgentManager}) {
    final dio = Dio(
      BaseOptions(
        headers: {HttpHeaders.userAgentHeader: userAgentManager?.current ?? UserAgentMixin.staticUserAgent},
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
    );

    final manager = userAgentManager;
    if (manager != null) {
      manager.attach(dio);
    }

    dio.interceptors.addAll([
      DioThrottlerInterceptor(
        const Duration(milliseconds: 200),
        onThrottled: (req, scheduled) {
          log.log(
            'Delay request for ${req.uri} until $scheduled',
            name: 'DioManager',
          );
        },
      ),
      DioRejectInterceptor(
        rejector: (options) {
          if (options.uri.pathSegments.isEmpty) {
            return DioException.requestCancelled(
              requestOptions: options,
              reason: Exception('Try to access domain without path'),
            );
          }

          return null;
        },
      ),
      log.interceptor,
    ]);

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 4,
        retryDelays: retryDelays,
        logPrint: (msg) => log.log(msg, name: 'DioManager'),
      ),
    );

    return dio;
  }
}
