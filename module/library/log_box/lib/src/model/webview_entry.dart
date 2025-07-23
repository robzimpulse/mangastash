import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/material/tabs.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../common/enum.dart';
import '../common/extension.dart';
import '../screen/detail/widget/item_column.dart';
import 'entry.dart';

class WebviewEntry extends Entry {
  final Uri? uri;

  final List<String> scripts;

  final List<WebviewEntryLog> events;

  final String? html;

  final Object? error;

  WebviewEntry({
    String? id,
    DateTime? timestamp,
    this.uri,
    this.scripts = const [],
    this.events = const [],
    this.html,
    this.error,
  }) : super(id: id, timestamp: timestamp);

  WebviewEntry copyWith({
    Uri? uri,
    List<String>? scripts,
    List<WebviewEntryLog>? events,
    String? html,
    Object? error,
  }) {
    return WebviewEntry(
      id: id,
      timestamp: timestamp,
      uri: uri ?? this.uri,
      scripts: scripts ?? this.scripts,
      events: events ?? this.events,
      html: html ?? this.html,
      error: error ?? this.error,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
    final theme = Theme.of(context);

    return {
      const Tab(
        text: 'Overview',
        icon: Icon(Icons.info, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'url', value: uri.toString()),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'scripts',
                    value: jsonEncode(scripts),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: timestamp.toIso8601String(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Html',
        icon: Icon(Icons.html, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Html', value: html),
                ),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Events',
        icon: Icon(Icons.event, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                for (final event in events.reversed)
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
                            child: ItemColumn(
                              name: 'Extra',
                              value: event.extra?.json,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      const Tab(
        text: 'Error',
        icon: Icon(Icons.warning, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Error', value: error.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }

  @override
  Widget title(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.web, size: 16),
            const SizedBox(width: 8),
            if (html == null && error == null) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                '${uri?.path}',
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
                '${uri?.host} (${events.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WebviewEntryLog {
  final WebviewEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  WebviewEntryLog({required this.event, this.extra})
    : timestamp = DateTime.timestamp();
}
