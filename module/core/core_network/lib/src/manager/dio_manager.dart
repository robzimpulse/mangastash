import 'package:dio/dio.dart';
import 'package:dio_inspector/dio_inspector.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:log_box/log_box.dart';
import 'package:universal_io/io.dart';

import '../interceptor/dio_throttler_interceptor.dart';
import '../mixin/user_agent_mixin.dart';

class DioManager {
  static Dio create({required DioInspector inspector, required LogBox log}) {
    final dio = Dio(
      BaseOptions(
        headers: {
          HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent,
        },
      ),
    );

    dio.interceptors.addAll(
      [
        inspector.getDioRequestInterceptor(),
        DioThrottlerInterceptor(
          const Duration(milliseconds: 200),
          onThrottled: (req, scheduled) => log.log(
            'Delay request for ${req.uri} until $scheduled',
            name: 'DioManager',
          ),
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
