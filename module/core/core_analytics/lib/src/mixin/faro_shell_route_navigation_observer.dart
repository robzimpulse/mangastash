import 'package:faro/src/faro.dart';
import 'package:flutter/widgets.dart';

import 'faro_mixin.dart';

class FaroShellRouteNavigationObserver extends RouteObserver with FaroMixin {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final prevRoute = previousRoute?.settings.name ?? FaroMixin.lastRoute;
    faro.setViewMeta(name: prevRoute);
    faro.pushEvent(
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
    faro.setViewMeta(name: route.settings.name);
    faro.pushEvent(
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
    faro.setViewMeta(name: currRoute);
    faro.pushEvent(
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
    faro.setViewMeta(name: route.settings.name);
    faro.pushEvent(
      'view_changed',
      attributes: {
        'fromView': prevRoute,
        'toView': route.settings.name,
      },
    );
    FaroMixin.lastRoute = route.settings.name;
  }
}
