import 'package:flutter/material.dart';

import '../../../common/extension.dart';
import '../../../model/entry.dart';
import '../../../model/webview_entry.dart';
import 'item_column.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({super.key, required this.data});

  final Entry data;

  @override
  Widget build(BuildContext context) {
    final data = this.data;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        if (data is WebviewEntry) ...[
          for (final event in data.events.reversed)
            SliverToBoxAdapter(
              child: ExpansionTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  event.event.name,
                  maxLines: 1,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  event.timestamp.toIso8601String(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                showTrailingIcon: event.extra?.json != null,
                children: [
                  if (event.extra?.json != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ItemColumn(name: 'Extra', value: event.extra?.json),
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
