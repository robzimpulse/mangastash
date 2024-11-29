import 'dart:developer';

import 'package:alice_lightweight/alice.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import '../interceptor/dio_throttler_interceptor.dart';

class DioManager {
  static Dio create({
    required Alice alice,
  }) {
    const userAgent = 'Mozilla/5.0 '
        '(Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/127.0.0.0 '
        'Safari/537.36';

    final dio = Dio(BaseOptions(headers: {'User-Agent': userAgent}))
      ..interceptors.addAll(
        [
          alice.getDioInterceptor(),
          DioThrottlerInterceptor(
            const Duration(milliseconds: 200),
            onThrottled: (req, scheduled) => log(
              'Delay request for ${req.uri} until $scheduled',
              name: 'DioManager',
              time: DateTime.now(),
            ),
          ),
        ],
      );

    return dio
      ..interceptors.add(
        RetryInterceptor(
          dio: dio,
          retryableExtraStatuses: {status400BadRequest},
          logPrint: (msg) => log(
            msg,
            name: 'DioManager',
            time: DateTime.now(),
          ),
        ),
      );
  }
}
