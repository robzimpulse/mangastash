import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:ui_common/ui_common.dart';

class MangaGridWidget extends StatefulWidget {
  const MangaGridWidget({
    super.key,
    this.onLoadNextPage,
    this.onTapPrefetch,
    this.onRefresh,
    this.onTapChapter,
    this.onTapRecrawl,
    this.absorber,
    this.error,
    this.isLoading = false,
    this.hasNext = false,
    this.mangas = const [],
    this.prefetchedMangaId = const {},
  });

  final VoidCallback? onLoadNextPage;

  final VoidCallback? onTapPrefetch;

  final RefreshCallback? onRefresh;

  final ValueSetter<Manga>? onTapChapter;

  final ValueSetter<String>? onTapRecrawl;

  final SliverOverlapAbsorberHandle? absorber;

  final Exception? error;

  final bool isLoading;

  final bool hasNext;

  final List<Manga> mangas;

  final Set<String> prefetchedMangaId;

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
    final error = widget.error;

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
              if (error != null) ...[
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
                              onPressed: () => widget.onTapRecrawl?.call(
                                error.url,
                              ),
                              child: const Text('Open Debug Browser'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (widget.mangas.isEmpty) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No Similar Manga',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SliverGrid.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: widget.isLoading
                      ? List.generate(
                          20,
                          (e) => Center(
                            child: Text('$e'),
                          ),
                        )
                      : [
                          for (final manga in widget.mangas)
                            const Center(
                              child: Text('data'),
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
