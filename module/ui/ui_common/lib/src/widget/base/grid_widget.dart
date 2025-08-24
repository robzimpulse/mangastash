import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'next_page_notification_widget.dart';
import 'shimmer_loading_widget.dart';

class GridWidget<T> extends StatefulWidget {
  const GridWidget({
    super.key,
    required this.itemBuilder,
    this.pageStorageKey,
    this.onLoadNextPage,
    this.onRefresh,
    this.onTapRecrawl,
    this.absorber,
    this.error,
    this.isLoading = false,
    this.hasNext = false,
    this.data = const [],
  });

  final PageStorageKey<String>? pageStorageKey;

  final VoidCallback? onLoadNextPage;

  final RefreshCallback? onRefresh;

  final Widget Function(BuildContext context, T data) itemBuilder;

  final ValueSetter<String>? onTapRecrawl;

  final SliverOverlapAbsorberHandle? absorber;

  final Exception? error;

  final bool isLoading;

  final bool hasNext;

  final List<T> data;

  @override
  State<GridWidget<T>> createState() => _GridWidgetState<T>();
}

class _GridWidgetState<T> extends State<GridWidget<T>> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    offset.value = widget.absorber?.layoutExtent ?? 0;
  }

  @override
  void didUpdateWidget(covariant GridWidget<T> oldWidget) {
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
    final error = widget.error;

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
          padding: const EdgeInsets.all(16),
          sliver: MultiSliver(
            children: [
              if (widget.isLoading)
                SliverGrid.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 100 / 140,
                  children: List.generate(
                    20,
                    (e) => LayoutBuilder(
                      builder: (context, constraint) {
                        return ConstrainedBox(
                          constraints: constraint,
                          child: ShimmerLoading.box(
                            radius: 0,
                            isLoading: true,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else if (error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Text(error.toString(), textAlign: TextAlign.center),
                          if (error is FailedParsingHtmlException) ...[
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                widget.onTapRecrawl?.call(error.url);
                              },
                              child: const Text('Open Debug Browser'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else if (widget.data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            EmojiAsciiEnum.crying.ascii,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          Text(
                            'Empty Data',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                SliverGrid.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 100 / 140,
                  children: [
                    for (final data in widget.data)
                      widget.itemBuilder.call(context, data),
                  ],
                ),
                if (widget.hasNext)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ],
          ),
        ),
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
