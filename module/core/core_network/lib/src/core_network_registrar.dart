/// Registers core_network's services into the shared [ServiceLocator].
///
/// Purpose: wires the headless webview runtime (`HeadlessWebviewManager`,
/// exposed as both `HeadlessWebviewUseCase` and `RunSourceScriptUseCase`),
/// the `UserAgentManager` and the shared Dio client.
/// Usage: `await CoreNetworkRegistrar().register(locator)` during bootstrap,
/// after `CoreAnalyticsRegistrar` (LogBox) and `CoreStorageRegistrar`
/// (`HtmlCacheManager`) — see `WrapperScreen` in `lib/main.dart`.
library;

import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/dio_manager.dart';
import 'manager/headless_webview_manager.dart';
import 'manager/user_agent_manager.dart';
import 'usecase/headless_webview_use_case.dart';
import 'usecase/run_source_script_use_case.dart';

class CoreNetworkRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerLazySingleton(
      () => HeadlessWebviewManager(
        log: locator(),
        htmlCacheManager: locator(),
        userAgentManager: locator(),
      ),
      dispose: (e) => e.dispose(),
    );
    locator.alias<HeadlessWebviewUseCase, HeadlessWebviewManager>();
    locator.alias<RunSourceScriptUseCase, HeadlessWebviewManager>();
    locator.registerLazySingleton(
      () => UserAgentManager(log: locator()),
    );
    locator.registerLazySingleton(
      () => DioManager.create(log: locator(), userAgentManager: locator()),
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
