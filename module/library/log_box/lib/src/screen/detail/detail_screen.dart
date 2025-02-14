import 'package:flutter/material.dart';

import '../../model/log_html_model.dart';
import '../../model/log_model.dart';
import '../webview/webview_screen.dart';
import 'widget/item_column.dart';

class DetailScreen extends StatelessWidget {
  final LogModel data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _appBar(context),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _overviewWidget(),
              _messageWidget(),
              _stackTraceWidget(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final data = this.data;
    return AppBar(
      title: const Text('Detail Activities'),
      elevation: 3,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        if (data is LogHtmlModel)
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebviewScreen(html: data.html),
              ),
            ),
            icon: const Icon(Icons.web),
          ),
      ],
      bottom: const TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(
            text: 'Overview',
            icon: Icon(Icons.info, color: Colors.white),
          ),
          Tab(
            text: 'Message',
            icon: Icon(Icons.message, color: Colors.white),
          ),
          Tab(
            text: 'Stack Trace',
            icon: Icon(Icons.list_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _overviewWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemColumn(name: 'Name', value: data.name),
            ItemColumn(name: 'Time', value: data.time?.toIso8601String()),
            ItemColumn(name: 'Sequence Number', value: '${data.sequenceNumber}'),
            ItemColumn(name: 'Level', value: '${data.level}'),

          ],
        ),
      ),
    );
  }

  Widget _messageWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemColumn(name: 'Message', value: data.message),
          ],
        ),
      ),
    );
  }

  Widget _stackTraceWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ItemColumn(name: 'Stack Trace', value: data.stackTrace.toString()),
          ],
        ),
      ),
    );
  }
}
