import 'package:flutter/material.dart';

import '../../../common/enum.dart';
import '../../../model/navigation_entry.dart';

class NavigationItemWidget extends StatelessWidget {
  final NavigationEntry data;

  const NavigationItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final icon = switch (data.action) {
      NavigationAction.push => Icons.arrow_forward,
      NavigationAction.pop => Icons.arrow_back,
      NavigationAction.remove => Icons.remove,
      NavigationAction.replace => Icons.change_circle,
    };

    final color = switch (data.action) {
      NavigationAction.push => Colors.green,
      NavigationAction.pop => Colors.red,
      NavigationAction.remove => Colors.grey,
      NavigationAction.replace => Colors.blue,
    };

    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                data.action.name.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
          Text('Route: ${data.route}', style: theme.textTheme.labelMedium),
          Text(
            'Previous: ${data.previousRoute}',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
      subtitle: Text(
        data.timestamp.toIso8601String(),
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
    );
  }
}
