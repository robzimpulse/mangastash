import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controller/paging_scroll_controller.dart';
import 'manga_shelf_item.dart';

class MangaShelfWidget extends StatelessWidget {
  final PagingScrollController controller;
  final List<MangaShelfItem> children;
  final bool isLoadingNextPage;
  final Widget loadingIndicator;
  final Widget contentSliverWidget;

  const MangaShelfWidget({
    super.key,
    required this.controller,
    required this.children,
    required this.isLoadingNextPage,
    required this.loadingIndicator,
    required this.contentSliverWidget,
  });

  MangaShelfWidget.list({
    super.key,
    required this.controller,
    required this.children,
    required this.isLoadingNextPage,
    required this.loadingIndicator,
    Widget? separator,
  }) : contentSliverWidget = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => index.isEven
                ? children[index ~/ 2]
                : separator ?? const SizedBox.shrink(),
            childCount: math.max(0, children.length * 2 - 1),
            semanticIndexCallback: (Widget _, int index) {
              return index.isEven ? index ~/ 2 : null;
            },
          ),
        );

  MangaShelfWidget.compactGrid({
    super.key,
    required this.controller,
    required this.children,
    required this.isLoadingNextPage,
    required this.loadingIndicator,
    required int crossAxisCount,
    required double childAspectRatio,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  }) : contentSliverWidget = SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: childAspectRatio,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
        );

  MangaShelfWidget.comfortableGrid({
    super.key,
    required this.controller,
    required this.children,
    required this.isLoadingNextPage,
    required this.loadingIndicator,
    required int crossAxisCount,
    required double childAspectRatio,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  }) : contentSliverWidget = SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: childAspectRatio,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        return controller.onScrollNotification(
          context,
          scrollNotification,
        );
      },
      child: CustomScrollView(
        controller: controller,
        slivers: [
          contentSliverWidget,
          if (isLoadingNextPage) _loadingIndicator(),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => loadingIndicator,
        childCount: 1,
      ),
    );
  }
}
