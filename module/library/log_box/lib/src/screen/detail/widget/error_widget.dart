import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../model/entry.dart';
import '../../../model/log_entry.dart';
import '../../../model/network_entry.dart';
import '../../../model/webview_entry.dart';
import 'item_column.dart';

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({super.key, required this.data});

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
                  child: ItemColumn(
                    name: 'Error',
                    value: data.error.toString(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Stack Trace',
                    value: data.stackTrace.toString(),
                  ),
                ),
              ] else if (data is NetworkEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Error',
                    value: data.error?.error.toString(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Stack Trace',
                    value: data.error?.stackTrace.toString(),
                  ),
                ),
              ] else if (data is WebviewEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Error',
                    value: data.error.toString(),
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