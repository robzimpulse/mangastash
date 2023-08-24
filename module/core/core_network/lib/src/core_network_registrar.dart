import 'package:alice_lightweight/alice.dart';
import 'package:dio/dio.dart';
import 'package:service_locator/service_locator.dart';

import 'client/manga_dex_dio.dart';
import 'manager/system_proxy_manager.dart';
import 'manager/url_launcher_manager.dart';
import 'use_case/get_proxy_use_case.dart';
import 'use_case/launch_url_use_case.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerSingleton(Alice());

    locator.registerFactory(() => MangaDexDio(alice: locator()));
    locator.alias<Dio, MangaDexDio>();

    locator.registerSingleton(await SystemProxyManager.init());
    locator.alias<GetSystemProxyUseCase, SystemProxyManager>();

    locator.registerSingleton(UrlLauncherManager());
    locator.alias<LaunchUrlUseCase, UrlLauncherManager>();
  }
}
