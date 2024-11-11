import 'dart:developer';

import 'package:background_worker/background_worker.dart';
import 'package:service_locator/service_locator.dart';

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
    log('start register', name: runtimeType.toString(), time: DateTime.now());
    locator.registerSingleton(ThemeManager(storage: locator()));
    locator.alias<UpdateThemeUseCase, ThemeManager>();
    locator.alias<ListenThemeUseCase, ThemeManager>();

    locator.registerSingleton(LocaleManager(storage: locator()));
    locator.alias<UpdateLocaleUseCase, LocaleManager>();
    locator.alias<ListenLocaleUseCase, LocaleManager>();

    locator.registerSingleton(await DateManager.create());
    locator.alias<ListenCurrentTimezoneUseCase, DateManager>();

    locator.registerSingleton(BackgroundWorker());
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
