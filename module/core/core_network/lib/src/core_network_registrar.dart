import 'package:cookie_jar/cookie_jar.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'usecase/headless_webview_usecase.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp().toIso8601String();

    final LogBox log = locator();

    locator.registerLazySingleton(
      () => HeadlessWebviewManager(log: log, storageManager: locator()),
    );
    locator.alias<HeadlessWebviewUseCase, HeadlessWebviewManager>();
    locator.registerLazySingleton(() => CookieJar());
    locator.registerLazySingleton(
      () => DioManager.create(log: locator(), cookieJar: locator()),
      dispose: (e) => e.close(force: true),
    );

    log.log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {'start': start, 'finish': DateTime.timestamp().toIso8601String()},
    );
  }
}
