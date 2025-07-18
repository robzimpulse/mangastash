import 'package:flutter/material.dart';

import '../../../common/extension.dart';
import '../../../model/log_entry.dart';

class LogItemWidget extends StatelessWidget {
  final LogEntry data;

  final VoidCallback? onTap;

  const LogItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      title: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.name ?? 'Logging',
                  maxLines: 1,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.message,
                  maxLines: 2,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        data.timestamp.dateTimeFormatted,
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
