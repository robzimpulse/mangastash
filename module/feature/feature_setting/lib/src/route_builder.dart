import 'package:core_route/core_route.dart';
import 'package:ui_setting/ui_setting.dart';

import 'route_path.dart';

class SettingRouteBuilder extends BaseRouteBuilder {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: SettingRoutePath.main,
        name: SettingRoutePath.main,
        builder: (context, state) => const SettingScreen(),
      ),
    ];
  }
}
