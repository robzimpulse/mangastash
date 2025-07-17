import 'package:flutter/material.dart';

import '../common/enum.dart';
import 'entry.dart';

class NavigationEntry extends Entry {
  final NavigationAction action;
  final String? route;
  final String? previousRoute;
  final DateTime timestamp;

  NavigationEntry._({
    required super.id,
    required this.action,
    this.route,
    this.previousRoute,
    required this.timestamp,
  });

  factory NavigationEntry.create({
    required String id,
    required NavigationAction action,
    String? route,
    String? previousRoute,
  }) {
    return NavigationEntry._(
      id: id,
      action: action,
      route: route,
      previousRoute: previousRoute,
      timestamp: DateTime.timestamp(),
    );
  }

  NavigationEntry copyWith({String? route, String? previousRoute}) {
    return NavigationEntry._(
      id: id,
      action: action,
      timestamp: timestamp,
      previousRoute: previousRoute ?? this.previousRoute,
      route: route ?? this.route,
    );
  }
}
