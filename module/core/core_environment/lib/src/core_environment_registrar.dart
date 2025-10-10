import 'package:core_analytics/core_analytics.dart';
import 'package:service_locator/service_locator.dart';

import 'manager/date_manager.dart';
import 'manager/locale_manager.dart';
import 'manager/theme_manager.dart';
import 'manager/worker_manager.dart';
import 'use_case/listen_current_timezone_use_case.dart';
import 'use_case/listen_locale_use_case.dart';
import 'use_case/listen_theme_use_case.dart';
import 'use_case/task_executor_use_case.dart';
import 'use_case/update_locale_use_case.dart';
import 'use_case/update_theme_use_case.dart';

class CoreEnvironmentRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();

    locator.registerLazySingleton(() => ThemeManager(storage: locator()));
    locator.alias<UpdateThemeUseCase, ThemeManager>();
    locator.alias<ListenThemeUseCase, ThemeManager>();

    locator.registerLazySingletonAsync(
      () => LocaleManager.create(storage: locator()),
    );
    locator.alias<UpdateLocaleUseCase, LocaleManager>();
    locator.alias<ListenLocaleUseCase, LocaleManager>();

    locator.registerLazySingletonAsync(() => DateManager.create());
    locator.alias<ListenCurrentTimezoneUseCase, DateManager>();

    locator.registerLazySingletonAsync(
      () => WorkerManager.create(),
      dispose: (e) => e.dispose(),
    );
    locator.alias<TaskExecutor, WorkerManager>();

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
}
