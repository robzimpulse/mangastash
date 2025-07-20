import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../common/extension.dart';
import '../../../model/entry.dart';
import '../../../model/log_entry.dart';
import 'item_column.dart';

class DetailWidget extends StatelessWidget {
  const DetailWidget({super.key, required this.data});

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
                  child: ItemColumn(name: 'Extra', value: data.extra.json),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

}