import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:super_paging/super_paging.dart';

import '../../util/typedef.dart';

class PaginatedListWidget<K, V> extends StatefulWidget {
  const PaginatedListWidget({
    super.key,
    this.pageStorageKey,
    this.absorber,
    this.padding = EdgeInsets.zero,
    this.onRefresh,

    required this.pager,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.separatorBuilder,
  });

  final Pager<K, V> pager;

  final PageStorageKey<String>? pageStorageKey;

  final SliverOverlapAbsorberHandle? absorber;

  final EdgeInsetsGeometry padding;

  final ElementWidgetBuilder<V> itemBuilder;

  final PagingStateEmptyBuilder emptyBuilder;

  final PagingStateErrorBuilder errorBuilder;

  final PagingStateLoadingBuilder loadingBuilder;

  final ElementWidgetBuilder<V>? separatorBuilder;

  final RefreshCallback? onRefresh;

  @override
  State<PaginatedListWidget<K, V>> createState() {
    return _PaginatedListWidgetState<K, V>();
  }
}

class _PaginatedListWidgetState<K, V> extends State<PaginatedListWidget<K, V>> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void didUpdateWidget(covariant PaginatedListWidget<K, V> oldWidget) {
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
          padding: widget.padding,
          sliver: PagingSliverList.separated(
            pager: widget.pager,
            itemBuilder: (context, index) {
              return widget.itemBuilder.call(
                context,
                widget.pager.items.elementAt(index),
              );
            },
            separatorBuilder: widget.separatorBuilder?.let((builder) {
              return (context, index) {
                return builder.call(
                  context,
                  widget.pager.items.elementAt(index),
                );
              };
            }),
            emptyBuilder: widget.emptyBuilder,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
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
