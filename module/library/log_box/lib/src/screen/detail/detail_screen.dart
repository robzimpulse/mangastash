import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../common/extension.dart';
import '../../model/entry.dart';
import '../../model/log_entry.dart';
import '../../model/network_entry.dart';
import '../../model/webview_entry.dart';
import 'widget/item_column.dart';

class DetailScreen extends StatelessWidget {
  final Entry data;

  final Function(String? url, String? html)? onTapSnapshot;

  const DetailScreen({super.key, required this.data, this.onTapSnapshot});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _appBar(context),
          body: SafeArea(
            child: TabBarView(
              children: [_overviewWidget(), _extraWidget(), _errorWidget()],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Detail Log'),
      elevation: 3,
      centerTitle: false,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      bottom: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(text: 'Overview', icon: Icon(Icons.info, color: Colors.white)),
          Tab(
            text: 'Detail',
            icon: Icon(Icons.data_array, color: Colors.white),
          ),
          Tab(text: 'Error', icon: Icon(Icons.error, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _overviewWidget() {
    final data = this.data;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: ItemColumn(
                  name: 'Timestamp',
                  value: data.timestamp.toIso8601String(),
                ),
              ),
              if (data is LogEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Name', value: data.name),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Message', value: data.message),
                ),
              ] else if (data is NetworkEntry) ...[
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Method', value: data.method),
                ),
                SliverToBoxAdapter(
                  child: ItemColumn(name: 'Url', value: data.uri),
                ),
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
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _extraWidget() {
    final data = this.data;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: MultiSliver(
            children: [
              if (data is LogEntry) ...[
                SliverToBoxAdapter(child: ItemColumn(name: 'Extra', value: data.extra.json)),
              ] else if (data is NetworkEntry) ...[
                // SliverToBoxAdapter(child: ItemColumn(name: 'Request', value: data.request?.json),),
                // SliverToBoxAdapter(child: ItemColumn(name: 'Response', value: data.request?.json),),
              ] else if (data is WebviewEntry) ...[
                SliverToBoxAdapter(child: ItemColumn(name: 'Html', value: data.html)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorWidget() {
    final data = this.data;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            if (data is LogEntry) ...[
              ItemColumn(name: 'Error', value: data.error.toString()),
              ItemColumn(
                name: 'Stack Trace',
                value: data.stackTrace.toString(),
              ),
            ] else if (data is NetworkEntry) ...[
              // TODO: add item column
            ] else if (data is WebviewEntry) ...[
              ItemColumn(name: 'Error', value: data.error.toString()),
            ],
          ],
        ),
      ),
    );
  }
}
