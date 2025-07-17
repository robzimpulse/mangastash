import 'package:flutter/material.dart' as material;

class NavigatorObserver extends material.NavigatorObserver {

  @override
  void didPush(material.Route route, material.Route? previousRoute) {
    // TODO: implement didPush
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(material.Route route, material.Route? previousRoute) {
    // TODO: implement didPop
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(material.Route route, material.Route? previousRoute) {
    // TODO: implement didRemove
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({material.Route? newRoute, material.Route? oldRoute}) {
    // TODO: implement didReplace
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didChangeTop(material.Route topRoute, material.Route? previousTopRoute) {
    // TODO: implement didChangeTop
    super.didChangeTop(topRoute, previousTopRoute);
  }

  @override
  void didStartUserGesture(material.Route route, material.Route? previousRoute) {
    // TODO: implement didStartUserGesture
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    // TODO: implement didStopUserGesture
    super.didStopUserGesture();
  }

}