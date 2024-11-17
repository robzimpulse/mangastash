import 'dart:developer';

import 'package:alice_lightweight/alice.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';
import 'manager/system_proxy_manager.dart';
import 'manager/url_launcher_manager.dart';
import 'use_case/get_proxy_use_case.dart';
import 'use_case/launch_url_use_case.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());
    locator.registerSingleton(Alice());

    locator.registerSingleton(await SystemProxyManager.create());
    locator.alias<GetSystemProxyUseCase, SystemProxyManager>();

    locator.registerSingleton(UrlLauncherManager());
    locator.alias<LaunchUrlUseCase, UrlLauncherManager>();

    locator.registerSingleton(DioManager.create(alice: locator()));
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
