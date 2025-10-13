import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';

class CoreAnalyticsRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();
    locator.registerLazySingleton(() => LogBox(capacity: 1000));
    // TODO: add analytics dependency here
    final end = DateTime.timestamp();
    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {
        'start': start.toIso8601String(),
        'finish': end.toIso8601String(),
        'duration': end.difference(start),
      },
    );
  }

  @override
  Future<void> isAllReady(ServiceLocator locator) async {

  }
}
