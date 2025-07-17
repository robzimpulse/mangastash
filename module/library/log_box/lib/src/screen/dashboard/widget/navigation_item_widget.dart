import 'package:flutter/material.dart';

import '../../../common/enum.dart';
import '../../../common/extension.dart';
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

    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 8),
              Text(data.action.name.toUpperCase()),
            ],
          ),
          Text(
            'Current: ${data.route}',
            style: theme.textTheme.labelMedium,
          ),
          Text(
            'Previous: ${data.previousRoute}',
            style: theme.textTheme.labelMedium,
          ),

          // Row(
          //   children: [
          //     Icon(icon, size: 16),
          //     const SizedBox(width: 8),
          //     Expanded(
          //       child: Text(
          //         data.message,
          //         maxLines: 2,
          //         style: theme.textTheme.labelLarge,
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      subtitle: Text(
        data.timestamp.dateTimeFormatted,
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
    );
  }
}
