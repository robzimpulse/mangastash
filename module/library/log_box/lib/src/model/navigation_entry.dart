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
}
