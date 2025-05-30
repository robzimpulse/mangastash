import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_updates/ui_updates.dart';

import 'route_path.dart';

class UpdatesRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: UpdatesRoutePath.updates,
      name: UpdatesRoutePath.updates,
      pageBuilder: (context, state) => NoTransitionPage(
        child: MangaUpdatesScreen.create(locator: locator),
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
