import 'package:service_locator/service_locator.dart';

import '../core_network.dart';
import 'manager/system_proxy_manager.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerSingleton(await SystemProxyManager.init());
    locator.alias<GetSystemProxyUseCase, SystemProxyManager>();
  }

}