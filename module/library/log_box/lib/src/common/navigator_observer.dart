import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:uuid/uuid.dart';

import '../model/entry.dart';
import '../model/navigation_entry.dart';
import 'enum.dart';

class NavigatorObserver extends material.NavigatorObserver {
  final ValueSetter<Entry> onEvent;

  NavigatorObserver({required this.onEvent});

  @override
  void didPush(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        id: const Uuid().v4(),
        action: NavigationAction.push,
        route: route,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didPop(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        id: const Uuid().v4(),
        action: NavigationAction.pop,
        route: route,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didRemove(material.Route route, material.Route? previousRoute) {
    onEvent(
      NavigationEntry(
        id: const Uuid().v4(),
        action: NavigationAction.remove,
        route: route,
        previousRoute: previousRoute,
      ),
    );
  }

  @override
  void didReplace({material.Route? newRoute, material.Route? oldRoute}) {
    onEvent(
      NavigationEntry(
        id: const Uuid().v4(),
        action: NavigationAction.replace,
        route: newRoute,
        previousRoute: oldRoute,
      ),
    );
  }

  @override
  void didChangeTop(material.Route topRoute, material.Route? previousTopRoute) {
    // TODO: implement didChangeTop
    super.didChangeTop(topRoute, previousTopRoute);
  }

  @override
  void didStartUserGesture(
    material.Route route,
    material.Route? previousRoute,
  ) {
    // TODO: implement didStartUserGesture
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    // TODO: implement didStopUserGesture
    super.didStopUserGesture();
  }
}
