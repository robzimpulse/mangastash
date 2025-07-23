import 'package:flutter/material.dart' hide ErrorWidget;

import '../../model/entry.dart';

class DetailScreen extends StatelessWidget {
  final Entry data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data.tabs(context).length,
      child: Scaffold(
        appBar: _appBar(context),
        body: SafeArea(
          child: TabBarView(
            children: [...data.tabs(context).values],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final data = this.data;

    return AppBar(
      title: const Text('Detail Log'),
      elevation: 3,
      centerTitle: false,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      // actions: [
      //   if (data is NetworkEntry)
      //     IconButton(
      //       onPressed: () {
      //         Helper.copyToClipboard(text: data.curl, context: context);
      //       },
      //       icon: const Icon(Icons.copy),
      //     ),
      // ],
      bottom: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: [...data.tabs(context).keys],
      ),
    );
  }
}
