import 'package:core_storage/core_storage.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:universal_io/io.dart';

import '../interceptor/dio_reject_interceptor.dart';
import '../interceptor/dio_throttler_interceptor.dart';
import '../mixin/user_agent_mixin.dart';

class DioManager {
  static Dio create({required LogBox log, required StorageManager storage}) {
    final dio = Dio(
      BaseOptions(
        headers: {HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent},
      ),
    );

    dio.interceptors.addAll([
      log.interceptor,
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
            return DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message: 'Try to access domain without path',
            );
          }
          return null;
        },
      ),
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
