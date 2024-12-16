import 'package:dio/dio.dart';
import 'package:dio_inspector/dio_inspector.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:log_box/log_box.dart';

import '../interceptor/dio_throttler_interceptor.dart';

class DioManager {
  static Dio create({required DioInspector inspector, required LogBox log}) {
    const userAgent = 'Mozilla/5.0 '
        '(Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/127.0.0.0 '
        'Safari/537.36';

    final dio = Dio(BaseOptions(headers: {'User-Agent': userAgent}))
      ..interceptors.addAll([
        inspector.getDioRequestInterceptor(),
        DioThrottlerInterceptor(
          const Duration(milliseconds: 200),
          onThrottled: (req, scheduled) => log.log(
            'Delay request for ${req.uri} until $scheduled',
            name: 'DioManager',
            time: DateTime.now(),
          ),
        ),
      ],);

    return dio
      ..interceptors.add(
        RetryInterceptor(
          dio: dio,
          retryableExtraStatuses: {status400BadRequest},
          logPrint: (msg) => log.log(
            msg,
            name: 'DioManager',
            time: DateTime.now(),
          ),
        ),
      );
  }
}
