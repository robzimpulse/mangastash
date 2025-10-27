import 'package:cookie_jar/cookie_jar.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'usecase/headless_webview_usecase.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerLazySingleton(
      () => HeadlessWebviewManager(
        log: locator(),
        htmlCacheManager: locator(),
        imageCacheManager: locator(),
      ),
    );
    locator.alias<HeadlessWebviewUseCase, HeadlessWebviewManager>();
    locator.registerLazySingleton(() => CookieJar());
    locator.registerLazySingleton(
      () => DioManager.create(log: locator(), cookieJar: locator()),
      dispose: (e) => e.close(force: true),
    );

    final end = DateTime.timestamp();

    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {
        'start': start.toIso8601String(),
        'finish': end.toIso8601String(),
        'duration': end.difference(start).toString(),
      },
    );
  }
}
