import 'dart:async';

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

  FutureOr<OnEnterResult?> onEnter({
    required BuildContext context,
    required GoRouterState current,
    required GoRouterState next,
    required GoRouter router,
  }) => null;
}

extension BaseRouteBuilders on List<BaseRouteBuilder> {
  List<RouteBase> aggregatedRoot({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return [
      for (final route in this)
        route.root(locator: locator, observers: observers),
    ];
  }

  List<RouteBase> aggregatedRoutes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      for (final route in this)
        ...route.routes(locator: locator, rootNavigatorKey: rootNavigatorKey),
    ];
  }

  List<RouteBase> aggregatedAllRoutes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return [
      for (final route in this)
        ...route.allRoutes(
          locator: locator,
          rootNavigatorKey: rootNavigatorKey,
          observers: observers,
        ),
    ];
  }

  FutureOr<OnEnterResult?> aggregatedOnEnter({
    required BuildContext context,
    required GoRouterState current,
    required GoRouterState next,
    required GoRouter router,
  }) async {
    for (final route in this) {
      final result = await route.onEnter(
        context: context,
        current: current,
        next: next,
        router: router,
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
