import 'package:flutter/material.dart';
import 'package:flutter/src/material/tabs.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../common/extension.dart';
import '../widget/item_column.dart';
import 'entry.dart';

class LogEntry extends Entry {
  final String message;
  final String? name;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> extra;

  LogEntry({
    String? id,
    DateTime? timestamp,
    required this.message,
    this.extra = const {},
    this.name,
    this.error,
    this.stackTrace,
  }) : super(id: id, timestamp: timestamp);

  LogEntry copyWith({
    String? message,
    String? name,
    Map<String, dynamic>? extra,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return LogEntry(
      id: id,
      timestamp: timestamp,
      name: name ?? this.name,
      message: message ?? this.message,
      extra: extra ?? this.extra,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  Map<Tab, Widget> tabs(BuildContext context) {
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
                  child: ItemColumn(name: 'Name', value: name),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Message', value: message),
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
        text: 'Detail',
        icon: Icon(Icons.list, color: Colors.white),
      ): CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Extra', value: extra.json),
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
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Stack Trace',
                    value: stackTrace.toString(),
                  ),
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
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.bug_report, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name ?? 'Logging',
                maxLines: 1,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
