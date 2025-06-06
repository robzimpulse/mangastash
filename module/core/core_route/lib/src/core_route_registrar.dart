import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/route_history_manager.dart';
import 'use_case/listen_current_route_setting_use_case.dart';
import 'use_case/update_current_route_setting_use_case.dart';

class CoreRouteRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      locator.registerSingleton(RouteHistoryManager());
      locator.alias<ListenCurrentRouteSettingUseCase, RouteHistoryManager>();
      locator.alias<UpdateCurrentRouteSettingUseCase, RouteHistoryManager>();
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
