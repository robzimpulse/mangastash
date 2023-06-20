import 'package:core_route/core_route.dart';
import 'package:ui_collection/ui_collection.dart';

import 'route_path.dart';

class CollectionRouteBuilder extends BaseRouteBuilder {
  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: CollectionRoutePath.main,
        name: CollectionRoutePath.main,
        builder: (context, state) => const CollectionScreen(),
      ),
    ];
  }
}
