import 'package:flutter/material.dart';

import '../common/enum.dart';
import 'entry.dart';

class NavigationEntry extends Entry {
  final NavigationAction action;
  final Route<dynamic>? route;
  final Route<dynamic>? previousRoute;
  final DateTime timestamp;

  NavigationEntry({
    required super.id,
    required this.action,
    this.route,
    this.previousRoute,
  }): timestamp = DateTime.timestamp();

  String get message {
    return [
      action.name.toUpperCase(),
      switch (action) {
        NavigationAction.push => 'To',
        NavigationAction.pop => 'From',
        NavigationAction.remove => 'From',
        NavigationAction.replace => 'With',
        NavigationAction.changeTop => 'With',
        NavigationAction.startUserGesture => 'On',
        NavigationAction.stopUserGesture => 'On',
      },
      switch (action) {
        NavigationAction.push => route,
        NavigationAction.pop => route,
        NavigationAction.remove => previousRoute,
        NavigationAction.replace => previousRoute,
        NavigationAction.changeTop => previousRoute,
        NavigationAction.startUserGesture => route,
        NavigationAction.stopUserGesture => route,
      }?.settings.name ?? 'Undefined',
    ].join(' ');
  }
}
