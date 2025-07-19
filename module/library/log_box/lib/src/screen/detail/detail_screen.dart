import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/extension.dart';
import '../../model/entry.dart';
import '../../model/log_entry.dart';
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
          Tab(text: 'Extra', icon: Icon(Icons.data_array, color: Colors.white)),
          Tab(text: 'Error', icon: Icon(Icons.error, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _overviewWidget() {
    final data = this.data;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            if (data is LogEntry) ...[
              ItemColumn(name: 'Name', value: data.name),
              ItemColumn(name: 'Message', value: data.message),
              ItemColumn(
                name: 'Timestamp',
                value: data.timestamp.toIso8601String(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _extraWidget() {
    final data = this.data;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            if (data is LogEntry) ...[
              ItemColumn(name: 'Extra', value: data.extra.json),
            ],
          ],
        ),
      ),
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
            ],
          ],
        ),
      ),
    );
  }
}
