import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../model/entry.dart';
import '../../../model/log_entry.dart';
import '../../../model/network_entry.dart';
import '../../../model/webview_entry.dart';
import 'item_column.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key, required this.data});

  final Entry data;

  @override
  Widget build(BuildContext context) {
    final data = this.data;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: MultiSliver(
            children: [
              if (data is LogEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Name', value: data.name),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Message', value: data.message),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: data.timestamp.toIso8601String(),
                  ),
                ),
              ] else if (data is NetworkEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Method', value: data.method),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Url', value: data.uri),
                ),
                ItemColumn(name: 'Duration', value: data.duration.toString()),
              ] else if (data is WebviewEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'url', value: data.uri.toString()),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'scripts',
                    value: jsonEncode(data.scripts),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: data.timestamp.toIso8601String(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

}