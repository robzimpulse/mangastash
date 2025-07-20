import 'package:flutter/material.dart' hide ErrorWidget;

import '../../model/entry.dart';
import '../../model/network_entry.dart';
import '../../model/webview_entry.dart';
import 'widget/detail_widget.dart';
import 'widget/error_widget.dart';
import 'widget/event_widget.dart';
import 'widget/html_widget.dart';
import 'widget/overview_widget.dart';
import 'widget/request_widget.dart';
import 'widget/response_widget.dart';

class DetailScreen extends StatelessWidget {
  final Entry data;

  final Function(String? url, String? html)? onTapSnapshot;

  const DetailScreen({super.key, required this.data, this.onTapSnapshot});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data is NetworkEntry || data is WebviewEntry ? 4 : 3,
      child: Scaffold(
        appBar: _appBar(context),
        body: SafeArea(
          child: TabBarView(
            children: [
              OverviewWidget(data: data),
              if (data is NetworkEntry) ...[
                RequestWidget(data: data),
                ResponseWidget(data: data),
              ] else if (data is WebviewEntry) ...[
                HtmlWidget(data: data),
                EventWidget(data: data),
              ] else
                DetailWidget(data: data),
              ErrorWidget(data: data),
            ],
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
      bottom: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: [
          const Tab(
            text: 'Overview',
            icon: Icon(Icons.info, color: Colors.white),
          ),
          if (data is NetworkEntry) ...[
            const Tab(
              text: 'Request',
              icon: Icon(Icons.arrow_upward, color: Colors.white),
            ),
            const Tab(
              text: 'Response',
              icon: Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ] else if (data is WebviewEntry) ...[
            const Tab(
              text: 'Html',
              icon: Icon(Icons.html, color: Colors.white),
            ),
            const Tab(
              text: 'Events',
              icon: Icon(Icons.event, color: Colors.white),
            ),
          ] else
            const Tab(
              text: 'Detail',
              icon: Icon(Icons.list, color: Colors.white),
            ),
          const Tab(
            text: 'Error',
            icon: Icon(Icons.warning, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
