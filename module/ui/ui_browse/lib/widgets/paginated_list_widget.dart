import 'package:feature_common/feature_common.dart';
import 'package:super_paging/super_paging.dart';

class PaginatedListWidget<K, V> extends StatefulWidget {
  const PaginatedListWidget({
    super.key,
    this.pageStorageKey,
    this.absorber,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,

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

  final int crossAxisCount;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  final IndexedWidgetBuilder itemBuilder;

  final PagingStateEmptyBuilder emptyBuilder;

  final PagingStateErrorBuilder errorBuilder;

  final PagingStateLoadingBuilder loadingBuilder;

  final IndexedWidgetBuilder? separatorBuilder;

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
        initialState: PagingState.fromPages(pager.pages),
      );
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
    return CustomScrollView(
      key: widget.pageStorageKey,
      slivers: [
        SliverToBoxAdapter(
          child: ValueListenableBuilder(
            valueListenable: offset,
            builder: (context, value, _) => SizedBox(height: value),
          ),
        ),
        PagingSliverList.separated(
          pager: pager,
          itemBuilder: widget.itemBuilder,
          separatorBuilder: widget.separatorBuilder,
          emptyBuilder: widget.emptyBuilder,
          errorBuilder: widget.errorBuilder,
          loadingBuilder: widget.loadingBuilder,
        ),
      ],
    );
  }
}
