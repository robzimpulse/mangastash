import 'package:dio_inspector/dio_inspector.dart';
import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';
import 'manager/system_proxy_manager.dart';
import 'use_case/get_proxy_use_case.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      locator.registerSingleton(
        await SystemProxyManager.create(log: locator()),
      );
      locator.alias<GetSystemProxyUseCase, SystemProxyManager>();

      locator.registerSingleton(DioInspector());

      locator.registerSingleton(
        DioManager.create(inspector: locator(), log: locator()),
      );
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
