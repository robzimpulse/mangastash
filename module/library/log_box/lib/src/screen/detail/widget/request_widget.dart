import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../common/extension.dart';
import '../../../model/entry.dart';
import '../../../model/network_entry.dart';
import 'item_column.dart';

class RequestWidget extends StatelessWidget {
  const RequestWidget({super.key, required this.data});

  final Entry data;

  @override
  Widget build(BuildContext context) {
    final data = this.data;

    return CustomScrollView(
      slivers: [
        if (data is NetworkEntry) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Timestamp',
                    value: data.request?.time.toIso8601String(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Headers',
                    value: data.request?.headers,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Query',
                    value: data.request?.queryParameters.json,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(
                    name: 'Body',
                    value: data.request?.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
