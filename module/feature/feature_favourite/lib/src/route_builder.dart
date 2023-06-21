import 'package:core_route/core_route.dart';
import 'package:ui_favourite/ui_favourite.dart';

import 'route_path.dart';

class FavouriteRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root() {
    return GoRoute(
      path: FavouriteRoutePath.main,
      name: FavouriteRoutePath.main,
      builder: (context, state) => const FavouriteScreen(),
    );
  }

  @override
  List<RouteBase> routes() {
    return [];
  }
}
