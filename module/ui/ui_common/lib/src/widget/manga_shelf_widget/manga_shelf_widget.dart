import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controller/paging_scroll_controller.dart';
import 'manga_shelf_item.dart';

class MangaShelfWidget extends StatelessWidget {
  final PagingScrollController controller;
  final List<MangaShelfItem> children;
  final bool hasNextPage;
  final Widget loadingIndicator;
  final Widget contentSliverWidget;
  final EdgeInsetsGeometry padding;

  const MangaShelfWidget({
    super.key,
    this.padding = const EdgeInsets.all(0),
    required this.controller,
    required this.children,
    required this.hasNextPage,
    required this.loadingIndicator,
    required this.contentSliverWidget,
  });

  MangaShelfWidget.list({
    super.key,
    this.padding = const EdgeInsets.all(0),
    required this.controller,
    required this.children,
    required this.hasNextPage,
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
    required this.hasNextPage,
    required this.loadingIndicator,
    required int crossAxisCount,
    required double childAspectRatio,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  })  : contentSliverWidget = SliverGrid(
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
        ),
        padding = EdgeInsets.symmetric(
          vertical: mainAxisSpacing,
          horizontal: crossAxisSpacing,
        );

  MangaShelfWidget.comfortableGrid({
    super.key,
    required this.controller,
    required this.children,
    required this.hasNextPage,
    required this.loadingIndicator,
    required int crossAxisCount,
    required double childAspectRatio,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
  })  : contentSliverWidget = SliverGrid(
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
        ),
        padding = EdgeInsets.symmetric(
          vertical: mainAxisSpacing,
          horizontal: crossAxisSpacing,
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
          SliverPadding(
            padding: padding,
            sliver: contentSliverWidget,
          ),
          if (hasNextPage) _loadingIndicator(),
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
