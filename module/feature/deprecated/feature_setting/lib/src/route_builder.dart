import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_setting/ui_setting.dart';

import 'route_path.dart';

class SettingRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      path: SettingRoutePath.main,
      name: SettingRoutePath.main,
      builder: (context, state) => SettingScreen(
        alice: locator.get(),
        listenThemeUseCase: locator(),
        themeUpdateUseCase: locator(),
      ),
      pageBuilder: (context, state) => NoTransitionPage(
        child: SettingScreen(
          alice: locator.get(),
          listenThemeUseCase: locator.get(),
          themeUpdateUseCase: locator.get(),
        ),
      ),
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return [];
  }
}
