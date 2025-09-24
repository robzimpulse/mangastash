import 'package:faro/src/faro.dart';
import 'package:flutter/widgets.dart';

import '../../core_analytics.dart';

class FaroShellRouteNavigationObserver extends RouteObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final prevRoute = previousRoute?.settings.name ?? FaroMixin.lastRoute;
    Faro().setViewMeta(name: prevRoute);
    Faro().pushEvent(
      'view_changed',
      attributes: {
        'fromView': route.settings.name,
        'toView': prevRoute,
      },
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final prevRoute = previousRoute?.settings.name ?? FaroMixin.lastRoute;
    Faro().setViewMeta(name: route.settings.name);
    Faro().pushEvent(
      'view_changed',
      attributes: {
        'fromView': prevRoute,
        'toView': route.settings.name,
      },
    );
    FaroMixin.lastRoute = route.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final prevRoute = oldRoute?.settings.name ?? FaroMixin.lastRoute;
    final currRoute = newRoute?.settings.name;
    Faro().setViewMeta(name: currRoute);
    Faro().pushEvent(
      'view_changed',
      attributes: {
        'fromView': prevRoute,
        'toView': currRoute,
      },
    );
    if (currRoute != null) FaroMixin.lastRoute = currRoute;
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final prevRoute = previousRoute?.settings.name ?? FaroMixin.lastRoute;
    Faro().setViewMeta(name: route.settings.name);
    Faro().pushEvent(
      'view_changed',
      attributes: {
        'fromView': prevRoute,
        'toView': route.settings.name,
      },
    );
    FaroMixin.lastRoute = route.settings.name;
  }
}
