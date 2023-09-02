import 'package:service_locator/service_locator.dart';

import 'manager/locale_manager.dart';
import 'manager/theme_manager.dart';
import 'use_case/get_language_list_use_case.dart';
import 'use_case/listen_locale_use_case.dart';
import 'use_case/listen_theme_use_case.dart';
import 'use_case/update_locale_use_case.dart';
import 'use_case/update_theme_use_case.dart';

class CoreEnvironmentRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerSingleton(ThemeManager(storage: locator()));
    locator.alias<UpdateThemeUseCase, ThemeManager>();
    locator.alias<ListenThemeUseCase, ThemeManager>();

    locator.registerSingleton(LocaleManager(storage: locator()));
    locator.alias<UpdateLocaleUseCase, LocaleManager>();
    locator.alias<ListenLocaleUseCase, LocaleManager>();
    locator.alias<GetLanguageListUseCase, LocaleManager>();
  }
}
