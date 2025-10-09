import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

class CoreAnalyticsRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp().toIso8601String();

    final log = LogBox(capacity: 1000);

    locator.registerSingleton(log);

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
