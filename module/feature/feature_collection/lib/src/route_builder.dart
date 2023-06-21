import 'package:core_route/core_route.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_collection/ui_collection.dart';

import 'route_path.dart';

class CollectionRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({required ServiceLocator locator}) {
    return GoRoute(
      path: CollectionRoutePath.main,
      name: CollectionRoutePath.main,
      builder: (context, state) => const CollectionScreen(),
    );
  }

  @override
  List<RouteBase> routes({required ServiceLocator locator}) {
    return [];
  }
}
