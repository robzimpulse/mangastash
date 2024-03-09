import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';

import 'route_path.dart';

class UpdatesRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: UpdatesRoutePath.updates,
      name: UpdatesRoutePath.updates,
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
  }) {
    return [];
  }
}
