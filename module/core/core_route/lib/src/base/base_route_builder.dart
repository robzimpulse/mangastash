import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:service_locator/service_locator.dart';

abstract class BaseRouteBuilder {
  RouteBase root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  });

  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  });

  List<RouteBase> allRoutes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return [
      root(locator: locator, observers: observers),
      ...routes(locator: locator, rootNavigatorKey: rootNavigatorKey),
    ];
  }
}
