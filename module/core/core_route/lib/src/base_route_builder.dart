import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:service_locator/service_locator.dart';

abstract class BaseRouteBuilder {
  RouteBase root({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  });

  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  });

  List<RouteBase> allRoutes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) {
    return [
      root(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
      ...routes(
        locator: locator,
        rootNavigatorKey: rootNavigatorKey,
        shellNavigatorKey: shellNavigatorKey,
      ),
    ];
  }
}
