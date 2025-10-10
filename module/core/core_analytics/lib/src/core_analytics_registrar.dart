import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

class CoreAnalyticsRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp().toIso8601String();

    locator.registerLazySingleton(() => LogBox(capacity: 1000));

    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
