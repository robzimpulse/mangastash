import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_favourite/ui_favourite.dart';

import 'route_path.dart';

class FavouriteRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({required ServiceLocator locator}) {
    return GoRoute(
      path: FavouriteRoutePath.main,
      name: FavouriteRoutePath.main,
      builder: (context, state) => const FavouriteScreen(),
    );
  }

  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [];
  }
}
