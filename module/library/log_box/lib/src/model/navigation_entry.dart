import 'package:flutter/material.dart';


import '../common/enum.dart';
import 'entry.dart';

class NavigationEntry extends Entry {
  final NavigationAction action;
  final String? route;
  final String? previousRoute;

  NavigationEntry({
    String? id,
    DateTime? timestamp,
    required this.action,
    this.route,
    this.previousRoute,
  }) : super(id: id, timestamp: timestamp);

  NavigationEntry copyWith({String? route, String? previousRoute}) {
    return NavigationEntry(
      id: id,
      timestamp: timestamp,
      action: action,
      previousRoute: previousRoute ?? this.previousRoute,
      route: route ?? this.route,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    return {};
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    final icon = switch (action) {
      NavigationAction.push => Icons.arrow_forward,
      NavigationAction.pop => Icons.arrow_back,
      NavigationAction.remove => Icons.remove,
      NavigationAction.replace => Icons.change_circle,
    };

    final color = switch (action) {
      NavigationAction.push => Colors.green,
      NavigationAction.pop => Colors.red,
      NavigationAction.remove => Colors.grey,
      NavigationAction.replace => Colors.blue,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              action.name.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
        Text('Route: $route', style: theme.textTheme.labelMedium),
        Text(
          'Previous: $previousRoute',
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}
