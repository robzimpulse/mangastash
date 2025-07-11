import 'package:ui_common/ui_common.dart';

class MangaGridWidget extends StatefulWidget {
  const MangaGridWidget({
    super.key,
    this.absorber,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadNextPage,
    this.hasNext = false,
  });

  final SliverOverlapAbsorberHandle? absorber;

  final bool isLoading;

  final RefreshCallback? onRefresh;

  final VoidCallback? onLoadNextPage;

  final bool hasNext;

  @override
  State<MangaGridWidget> createState() => _MangaGridWidgetState();
}

class _MangaGridWidgetState extends State<MangaGridWidget> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    offset.value = widget.absorber?.layoutExtent ?? 0;
  }

  @override
  void didUpdateWidget(covariant MangaGridWidget oldWidget) {
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

    Widget view = CustomScrollView(
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
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 100 / 140,
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => LayoutBuilder(
                  builder: (context, constraint) => ConstrainedBox(
                    constraints: constraint,
                    // TODO: change to manga image
                    child: Container(
                      color: Colors.grey,
                      child: Center(
                        child: Text('$index'),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.hasNext)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
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
