import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key, required this.onTapSearchSource});

  final Function(BuildContext) onTapSearchSource;

  static Widget create({
    required ServiceLocator locator,
    required Function(BuildContext) onTapSearchSource,
  }) {
    return BrowseScreen(
      onTapSearchSource: onTapSearchSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Browse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_search_desktop_outlined),
            onPressed: () => onTapSearchSource.call(context),
          )
        ],
      ),
      body: AdaptivePhysicListView(
        children: [],
      ),
    );
  }
}
