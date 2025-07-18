import 'package:flutter/material.dart';

import '../../../common/extension.dart';
import '../../../model/network_entry.dart';

class NetworkItemWidget extends StatelessWidget {
  final NetworkEntry data;

  final VoidCallback? onTap;

  const NetworkItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final start = data.request?.time;
    final stop = data.response?.time;

    return ListTile(
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      title: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.public, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${data.method ?? 'Undefined'} ${data.server}',
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
                  '${data.endpoint}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${start?.dateTimeFormatted} ',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),

          Text(
            '${stop?.dateTimeFormatted} ',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
