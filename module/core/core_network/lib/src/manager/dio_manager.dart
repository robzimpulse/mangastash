import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:universal_io/io.dart';

import '../interceptor/dio_reject_interceptor.dart';
import '../interceptor/dio_throttler_interceptor.dart';
import '../mixin/user_agent_mixin.dart';

class DioManager {
  static Dio create({
    required LogBox log,
    required AppDatabase db,
  }) {
    final dio = Dio(
      BaseOptions(
        headers: {
          HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent,
        },
      ),
    );

    dio.interceptors.addAll(
      [
        log.interceptor,
        DioThrottlerInterceptor(
          const Duration(milliseconds: 200),
          onThrottled: (req, scheduled) => log.log(
            'Delay request for ${req.uri} until $scheduled',
            name: 'DioManager',
          ),
        ),
        DioCacheInterceptor(
          options: CacheOptions(
            store: DioCacheStore(db: db),
            hitCacheOnNetworkFailure: true,
          ),
        ),
        DioRejectInterceptor(
          rejector: (options) => options.uri.pathSegments.isEmpty
              ? DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                  message: 'Try to access domain without path',
                )
              : null,
        ),
      ],
    );

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
