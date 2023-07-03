import 'package:flutter/material.dart';

import '../controller/paging_scroll_controller.dart';
import 'manga_grid_item_widget.dart';

class MangaGridWidget extends StatelessWidget {
  final PagingScrollController controller;

  final List<MangaGridItemWidget> children;

  final int crossAxisCount;

  final double childAspectRatio;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final bool isLoadingNextPage;

  final Widget loadingIndicator;

  const MangaGridWidget({
    super.key,
    required this.controller,
    required this.children,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.isLoadingNextPage,
    required this.loadingIndicator,
  });

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
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: childAspectRatio,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => children.toList()[index],
              childCount: children.length,
            ),
          ),
          if (isLoadingNextPage)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => loadingIndicator,
                childCount: 1,
              ),
            ),
        ],
      ),
    );
  }
}
