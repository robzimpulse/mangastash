import 'package:flutter/widgets.dart';
import 'package:log_box/log_box.dart';

class BaseRouteObserver extends NavigatorObserver {
  final LogBox log;

  BaseRouteObserver({required this.log});

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
    if (location == null) return;
    log.log(
      'location: $location\narguments: $arguments',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );
  }
}
