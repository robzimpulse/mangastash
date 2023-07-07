import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_collection/ui_collection.dart';

import 'route_path.dart';

class CollectionRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      path: CollectionRoutePath.main,
      name: CollectionRoutePath.main,
      builder: (context, state) => const CollectionScreen(),
      pageBuilder: (context, state) => const NoTransitionPage(
        child: CollectionScreen(),
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
