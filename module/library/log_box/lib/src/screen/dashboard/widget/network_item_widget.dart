import 'package:flutter/material.dart';

import '../../../model/network_entry.dart';

class NetworkItemWidget extends StatelessWidget {
  final NetworkEntry data;

  final VoidCallback? onTap;

  const NetworkItemWidget({super.key, required this.data, this.onTap});

  Color? _color() {
    final status = data.response?.status;

    if (status == null) return null;

    if (status >= 200 && status < 300) {
      return Colors.green;
    } else if (status >= 300 && status < 400) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _status(BuildContext context) {
    if (data.loading == true) {
      return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final status = data.response?.status;
    if (status != null) {
      return Text(
        '$status',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(color: _color()),
      );
    }

    return Text(
      'ERROR',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelLarge?.copyWith(color: Colors.red),
    );
  }

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
              Icon(Icons.public, size: 16, color: _color()),
              const SizedBox(width: 8),
              _status(context),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${data.method ?? 'Undefined'} ${data.uri?.path}',
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
                  '${data.uri?.host}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        '${data.request?.time.toIso8601String()} ',
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
