import 'package:cookie_jar/cookie_jar.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:universal_io/io.dart';

import '../interceptor/dio_reject_interceptor.dart';
import '../interceptor/dio_throttler_interceptor.dart';
import '../mixin/user_agent_mixin.dart';

class DioManager {
  static Dio create({
    required LogBox log,
    required CookieJar cookieJar,
  }) {
    final dio = Dio(
      BaseOptions(
        headers: {HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent},
      ),
    );

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
      CookieManager(cookieJar),
      log.interceptor,
    ]);

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retryableExtraStatuses: {status400BadRequest},
        logPrint: (msg) => log.log(msg, name: 'DioManager'),
      ),
    );

    return dio;
  }
}
