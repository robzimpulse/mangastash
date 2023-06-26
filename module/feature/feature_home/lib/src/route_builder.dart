import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_home/ui_home.dart';

import 'route_path.dart';

class HomeRouteBuilder extends BaseRouteBuilder {

  @override
  GoRoute root({required ServiceLocator locator}) {
    return GoRoute(
      path: HomeRoutePath.main,
      name: HomeRoutePath.main,
      builder: (context, state) => HomeScreen.create(locator: locator),
    );
  }

  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [];
  }
}
