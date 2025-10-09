import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

class CoreRouteRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp().toIso8601String();

    final LogBox log = locator();

    // TODO: register any manager here

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
