import 'package:flutter/material.dart';

import '../../../model/webview_entry.dart';

class WebviewItemWidget extends StatelessWidget {
  final WebviewEntry data;

  final VoidCallback? onTap;

  const WebviewItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      title: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.web, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${data.uri?.path}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${data.uri?.host} (${data.events.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        '${data.timestamp.toIso8601String()} ',
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
