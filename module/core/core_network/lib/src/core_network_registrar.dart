import 'dart:developer';

import 'package:alice_lightweight/alice.dart';
import 'package:dio/dio.dart';
import 'package:service_locator/service_locator.dart';

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
      () => Dio()
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
        ),
    );
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
