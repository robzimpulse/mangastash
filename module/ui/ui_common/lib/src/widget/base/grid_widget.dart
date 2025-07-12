import 'package:flutter/material.dart';

import 'next_page_notification_widget.dart';

class GridWidget extends StatefulWidget {
  const GridWidget({
    super.key,
    this.controller,
    this.absorber,
    this.hasNextPage = false,
    this.isLoading = false,
    this.loadingIndicator = const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Center(child: CircularProgressIndicator()),
    ),
    this.onRefresh,
    this.onLoadNextPage,
    required this.builder,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
  });

  final SliverOverlapAbsorberHandle? absorber;
  final bool isLoading;
  final RefreshCallback? onRefresh;
  final VoidCallback? onLoadNextPage;
  final ScrollController? controller;
  final NullableIndexedWidgetBuilder builder;
  final bool hasNextPage;
  final Widget loadingIndicator;
  final double spacing;
  final double childAspectRatio;
  final int crossAxisCount;

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    offset.value = widget.absorber?.layoutExtent ?? 0;
  }

  @override
  void didUpdateWidget(covariant GridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.absorber != widget.absorber) {
      offset.value = widget.absorber?.layoutExtent ?? 0;
    }
  }

  @override
  void dispose() {
    offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onRefresh = widget.onRefresh;

    final view = CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverToBoxAdapter(
          child: ValueListenableBuilder(
            valueListenable: offset,
            builder: (context, value, _) => SizedBox(height: value),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: widget.spacing,
            horizontal: widget.spacing,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: widget.childAspectRatio,
              crossAxisCount: widget.crossAxisCount,
              mainAxisSpacing: widget.spacing,
              crossAxisSpacing: widget.spacing,
            ),
            delegate: SliverChildBuilderDelegate(widget.builder),
          ),
        ),
        if (widget.hasNextPage)
          SliverToBoxAdapter(child: widget.loadingIndicator),
      ],
    );

    return NextPageNotificationWidget(
      onLoadNextPage: widget.onLoadNextPage,
      child: ValueListenableBuilder(
        valueListenable: offset,
        builder: (context, value, child) {
          if (onRefresh == null) return child ?? const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: onRefresh,
            edgeOffset: value,
            child: child ?? const SizedBox.shrink(),
          );
        },
        child: view,
      ),
    );
  }
}
