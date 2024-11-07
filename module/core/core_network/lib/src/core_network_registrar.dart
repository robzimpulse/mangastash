import 'dart:developer';

import 'package:alice_lightweight/alice.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:service_locator/service_locator.dart';

import '../core_network.dart';
import 'interceptor/dio_throttler_interceptor.dart';
import 'manager/system_proxy_manager.dart';
import 'manager/url_launcher_manager.dart';
import 'use_case/get_proxy_use_case.dart';
import 'use_case/launch_url_use_case.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());
    locator.registerSingleton(Alice());

    locator.registerSingleton(await SystemProxyManager.init());
    locator.alias<GetSystemProxyUseCase, SystemProxyManager>();

    locator.registerSingleton(UrlLauncherManager());
    locator.alias<LaunchUrlUseCase, UrlLauncherManager>();

    locator.registerFactory(
      () {
        const userAgent = 'Mozilla/5.0 '
            '(Macintosh; Intel Mac OS X 10_15_7) '
            'AppleWebKit/537.36 (KHTML, like Gecko) '
            'Chrome/127.0.0.0 '
            'Safari/537.36';
        final dio = Dio(BaseOptions(headers: {'User-Agent': userAgent}))
          ..interceptors.addAll(
            [
              locator<Alice>().getDioInterceptor(),
              DioThrottlerInterceptor(
                const Duration(seconds: 1),
                onThrottled: (req, scheduled) => log(
                  'Delay request for ${req.uri} until $scheduled',
                  name: runtimeType.toString(),
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
                name: runtimeType.toString(),
                time: DateTime.now(),
              ),
            ),
          );
      },
    );
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
