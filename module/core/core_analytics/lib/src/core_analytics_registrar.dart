import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

class CoreAnalyticsRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {

    final log = LogBox(capacity: 1000);

    log.log(
      'Register ${runtimeType.toString()}',
      name: 'Services',
      id: runtimeType.toString(),
      extra: {'start': DateTime.timestamp().toIso8601String()},
    );

    locator.registerSingleton(log);

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}