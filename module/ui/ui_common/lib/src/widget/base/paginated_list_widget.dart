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

    this.initialKey,
    required this.config,
    required this.source,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.separatorBuilder,
  });

  final K? initialKey;

  final PagingConfig config;

  final PagingSource<K, V> source;

  final PageStorageKey<String>? pageStorageKey;

  final SliverOverlapAbsorberHandle? absorber;

  final EdgeInsetsGeometry padding;

  final ElementWidgetBuilder<V> itemBuilder;

  final PagingStateEmptyBuilder emptyBuilder;

  final PagingStateErrorBuilder errorBuilder;

  final PagingStateLoadingBuilder loadingBuilder;

  final ElementWidgetBuilder<V>? separatorBuilder;

  @override
  State<PaginatedListWidget<K, V>> createState() {
    return _PaginatedListWidgetState<K, V>();
  }
}

class _PaginatedListWidgetState<K, V> extends State<PaginatedListWidget<K, V>> {
  late Pager<K, V> pager;
  late ValueNotifier<double> offset;

  @override
  void initState() {
    pager = Pager(
      initialKey: widget.initialKey,
      config: widget.config,
      pagingSourceFactory: () => widget.source,
    );
    offset = ValueNotifier(0);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PaginatedListWidget<K, V> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldReInitPager = [
      oldWidget.initialKey != widget.initialKey,
      oldWidget.config != widget.config,
      oldWidget.source != widget.source,
    ].any((e) => e);

    if (shouldReInitPager) {
      pager = Pager(
        initialKey: widget.initialKey,
        config: widget.config,
        pagingSourceFactory: () => widget.source,
      )..refresh(resetPages: true);
    }

    if (oldWidget.absorber != widget.absorber) {
      offset.value = widget.absorber?.layoutExtent ?? 0;
    }
  }

  @override
  void dispose() {
    pager.dispose();
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
            pager: pager,
            itemBuilder: (context, index) {
              return widget.itemBuilder.call(
                context,
                pager.items.elementAt(index),
              );
            },
            separatorBuilder: widget.separatorBuilder?.let((builder) {
              return (context, index) {
                return builder.call(context, pager.items.elementAt(index));
              };
            }),
            emptyBuilder: widget.emptyBuilder,
            errorBuilder: widget.errorBuilder,
            loadingBuilder: widget.loadingBuilder,
          ),
        ),
      ],
    );

    return ValueListenableBuilder(
      valueListenable: offset,
      builder: (context, value, child) {
        return RefreshIndicator(
          onRefresh: () => pager.refresh(resetPages: true),
          edgeOffset: value,
          child: child ?? const SizedBox.shrink(),
        );
      },
      child: view,
    );
  }
}
