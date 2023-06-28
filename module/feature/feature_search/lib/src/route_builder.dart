import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_search/ui_search.dart';

import 'route_path.dart';

class SearchRouteBuilder extends BaseRouteBuilder {

  @override
  GoRoute root({required ServiceLocator locator}) {
    return GoRoute(
      path: SearchRoutePath.main,
      name: SearchRoutePath.home,
      builder: (context, state) => SearchScreen.create(locator: locator),
    );
  }

  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [];
  }
}