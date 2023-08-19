import 'package:alice_lightweight/alice.dart';
import 'package:service_locator/service_locator.dart';

import '../core_network.dart';
import 'client/manga_dex_dio.dart';
import 'manager/system_proxy_manager.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerLazySingleton(() => Alice());

    locator.registerFactory(() => MangaDexDio(alice: locator()));
    locator.alias<Dio, MangaDexDio>();

    locator.registerSingleton(await SystemProxyManager.init());
    locator.alias<GetSystemProxyUseCase, SystemProxyManager>();
  }
}
