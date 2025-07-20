import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../model/entry.dart';
import '../../../model/webview_entry.dart';
import 'item_column.dart';

class HtmlWidget extends StatelessWidget {
  const HtmlWidget({super.key, required this.data});

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
              if (data is WebviewEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Html', value: data.html),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

}