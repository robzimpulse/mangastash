import 'dart:developer';

import 'package:flutter/widgets.dart';

class BaseRouteObserver extends NavigatorObserver {
  BaseRouteObserver();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _update(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _update(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _update(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _update(newRoute);
  }

  void _update(Route? route) {
    final location = route?.settings.name;
    final arguments = route?.settings.arguments;
    log('location: $location', name: 'robzimpulse');
    log('arguments: $arguments', name: 'robzimpulse');
  }
}
