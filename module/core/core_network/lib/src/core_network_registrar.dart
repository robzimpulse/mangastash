import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': DateTime.timestamp().toIso8601String()},
    );

    locator.registerSingleton(
      DioManager.create(log: locator(), storage: locator()),
      dispose: (e) => e.close(force: true),
    );

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
