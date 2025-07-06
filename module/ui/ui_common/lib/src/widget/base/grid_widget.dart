import 'package:flutter/material.dart';

class GridWidget extends StatelessWidget {
  const GridWidget({
    super.key,
    required this.controller,
    required this.builder,
    this.hasNextPage = false,
    this.loadingIndicator = const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(child: CircularProgressIndicator()),
    ),
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  });

  final ScrollController controller;
  final NullableIndexedWidgetBuilder builder;
  final bool hasNextPage;
  final Widget loadingIndicator;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: mainAxisSpacing,
            horizontal: crossAxisSpacing,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: childAspectRatio,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(builder),
          ),
        ),
        if (hasNextPage) SliverToBoxAdapter(child: loadingIndicator),
      ],
    );
  }
}
