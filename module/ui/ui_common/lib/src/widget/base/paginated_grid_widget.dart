import 'package:flutter/material.dart';
import 'package:super_paging/super_paging.dart';

import '../../util/typedef.dart';

class PaginatedGridWidget<K, V> extends StatefulWidget {
  const PaginatedGridWidget({
    super.key,
    this.pageStorageKey,
    this.absorber,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.onRefresh,

    required this.pager,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    required this.loadingBuilder,
  });

  final Pager<K, V> pager;

  final PageStorageKey<String>? pageStorageKey;

  final SliverOverlapAbsorberHandle? absorber;

  final int crossAxisCount;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  final ElementWidgetBuilder<V> itemBuilder;

  final PagingStateEmptyBuilder emptyBuilder;

  final PagingStateErrorBuilder errorBuilder;

  final PagingStateLoadingBuilder loadingBuilder;

  final RefreshCallback? onRefresh;

  @override
  State<PaginatedGridWidget<K, V>> createState() {
    return _PaginatedGridWidgetState<K, V>();
  }
}

class _PaginatedGridWidgetState<K, V> extends State<PaginatedGridWidget<K, V>> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void didUpdateWidget(covariant PaginatedGridWidget<K, V> oldWidget) {
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
    Widget view = CustomScrollView(
      key: widget.pageStorageKey,
      slivers: [
        SliverToBoxAdapter(
          child: ValueListenableBuilder(
            valueListenable: offset,
            builder: (context, value, _) => SizedBox(height: value),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: widget.mainAxisSpacing,
            horizontal: widget.crossAxisSpacing,
          ),
          sliver: PagingSliverGrid.count(
            pager: widget.pager,
            itemBuilder: (context, index) {
              return widget.itemBuilder.call(
                context,
                widget.pager.items.elementAt(index),
              );
            },
            emptyBuilder: widget.emptyBuilder,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childAspectRatio: widget.childAspectRatio,
          ),
        ),
      ],
    );

    final onRefresh = widget.onRefresh;
    return ValueListenableBuilder(
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
    );
  }
}
