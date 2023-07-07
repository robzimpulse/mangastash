import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';

import 'route_path.dart';

class MoreRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return GoRoute(
      path: MoreRoutePath.more,
      name: MoreRoutePath.more,
      // TODO: implement ui
      builder: (context, state) => const SizedBox.shrink(),
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SizedBox.shrink(),
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