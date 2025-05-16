import 'package:log_box/log_box.dart';
import 'package:service_locator/service_locator.dart';
import 'package:worker_manager/worker_manager.dart';

import 'manager/date_manager.dart';
import 'manager/locale_manager.dart';
import 'manager/theme_manager.dart';
import 'use_case/listen_current_timezone_use_case.dart';
import 'use_case/listen_locale_use_case.dart';
import 'use_case/listen_theme_use_case.dart';
import 'use_case/update_locale_use_case.dart';
import 'use_case/update_theme_use_case.dart';

class CoreEnvironmentRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    final MeasureProcessUseCase measurement = locator();

    await measurement.execute(() async {
      locator.registerSingleton(ThemeManager(storage: locator()));
      locator.alias<UpdateThemeUseCase, ThemeManager>();
      locator.alias<ListenThemeUseCase, ThemeManager>();

      locator.registerSingleton(await LocaleManager.create(storage: locator()));
      locator.alias<UpdateLocaleUseCase, LocaleManager>();
      locator.alias<ListenLocaleUseCase, LocaleManager>();

      locator.registerSingleton(await DateManager.create());
      locator.alias<ListenCurrentTimezoneUseCase, DateManager>();

      await workerManager.init(dynamicSpawning: true);
    });

    log.log(
      'Finish Register ${runtimeType.toString()}',
      name: 'Services',
      extra: {'duration': measurement.elapsed},
    );
  }
}
