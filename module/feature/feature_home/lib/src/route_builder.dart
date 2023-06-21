import 'package:core_route/core_route.dart';
import 'package:ui_home/ui_home.dart';

import 'route_path.dart';

class HomeRouteBuilder extends BaseRouteBuilder {

  @override
  GoRoute root() {
    return GoRoute(
      path: HomeRoutePath.main,
      name: HomeRoutePath.main,
      builder: (context, state) => const HomeScreen(),
    );
  }

  @override
  List<RouteBase> routes() {
    return [];
  }
}
