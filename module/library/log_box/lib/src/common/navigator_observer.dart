import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;

import '../model/navigation_entry.dart';
import 'enum.dart';

class NavigatorObserver extends material.NavigatorObserver {
  final ValueSetter<NavigationEntry> onEvent;

  NavigatorObserver({required this.onEvent});

  @override
  void didPush(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        action: NavigationAction.push,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didPop(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        action: NavigationAction.pop,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didRemove(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        action: NavigationAction.remove,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didReplace({material.Route? newRoute, material.Route? oldRoute}) {
    onEvent(
      NavigationEntry(
        action: NavigationAction.replace,
        route: newRoute?.settings.name,
        previousRoute: oldRoute?.settings.name,
      ),
    );
  }
}
