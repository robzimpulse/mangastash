import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'base/next_page_notification_widget.dart';
import 'base/shimmer_loading_widget.dart';
import 'chapter_tile_widget.dart';

class ChapterListWidget extends StatefulWidget {
  const ChapterListWidget({
    super.key,
    this.pageStorageKey,
    this.onLoadNextPage,
    this.onRefresh,
    this.absorber,
    this.error,
    this.isLoading = true,
    this.hasNext = false,
    this.chapters = const [],
    this.onTapRecrawl,
    this.prefetchedChapterId = const {},
    this.onTapChapter,
    this.total = 0,
    this.onTapDownload,
    this.onTapFilter,
    this.onTapPrefetch,
  });

  final PageStorageKey<String>? pageStorageKey;

  final VoidCallback? onLoadNextPage;

  final ValueSetter<DownloadOption>? onTapDownload;

  final VoidCallback? onTapFilter;

  final VoidCallback? onTapPrefetch;

  final RefreshCallback? onRefresh;

  final ValueSetter<String>? onTapRecrawl;

  final ValueSetter<Chapter>? onTapChapter;

  final SliverOverlapAbsorberHandle? absorber;

  final Exception? error;

  final bool isLoading;

  final bool hasNext;

  final List<Chapter> chapters;

  final Set<String> prefetchedChapterId;

  final int total;

  @override
  State<ChapterListWidget> createState() => _ChapterListWidgetState();
}

class _ChapterListWidgetState extends State<ChapterListWidget> {
  final ValueNotifier<double> offset = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    offset.value = widget.absorber?.layoutExtent ?? 0;
  }

  @override
  void didUpdateWidget(covariant ChapterListWidget oldWidget) {
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.isLoading ? 12 : 0,
                  ),
                  child: Row(
                    children: [
                      ShimmerLoading.multiline(
                        isLoading: widget.isLoading,
                        width: 50,
                        height: 15,
                        lines: 1,
                        child: Text(
                          '${widget.total} Chapters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Spacer(),
                      ShimmerLoading.multiline(
                        isLoading: widget.isLoading,
                        width: 56,
                        height: 24,
                        lines: 1,
                        child: PopupMenuButton<DownloadOption>(
                          icon: const Icon(Icons.download),
                          onSelected: (value) => widget.onTapDownload?.call(
                            value,
                          ),
                          itemBuilder: (context) => [
                            ...DownloadOption.values.map(
                              (e) => PopupMenuItem<DownloadOption>(
                                value: e,
                                child: Text(e.value),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isLoading) const SizedBox(width: 4),
                      ShimmerLoading.multiline(
                        isLoading: widget.isLoading,
                        width: 56,
                        height: 24,
                        lines: 1,
                        child: IconButton(
                          icon: const Icon(Icons.cloud_download),
                          onPressed: () => widget.onTapPrefetch?.call(),
                        ),
                      ),
                      if (widget.isLoading) const SizedBox(width: 4),
                      ShimmerLoading.multiline(
                        isLoading: widget.isLoading,
                        width: 56,
                        height: 24,
                        lines: 1,
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () => widget.onTapFilter?.call(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isLoading)
                SliverList.separated(
                  itemBuilder: (context, index) => ShimmerLoading.multiline(
                    isLoading: true,
                    width: double.infinity,
                    height: 15,
                    lines: 3,
                  ),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 4,
                  ),
                  itemCount: 30,
                )
              else if (error != null) ...[
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
              ] else if (widget.chapters.isEmpty) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No Chapter', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SliverList.separated(
                  itemBuilder: (context, index) {
                    final chapter = widget.chapters.elementAtOrNull(index);
                    if (chapter == null) return null;
                    return ChapterTileWidget(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onTap: () => widget.onTapChapter?.call(chapter),
                      opacity: chapter.lastReadAt != null ? 0.5 : 1,
                      title: [
                        'Chapter ${chapter.chapter}',
                        chapter.title,
                      ].nonNulls.join(' - '),
                      language: Language.fromCode(chapter.translatedLanguage),
                      uploadedAt: chapter.readableAt,
                      groups: chapter.scanlationGroup,
                      isPrefetching:
                          widget.prefetchedChapterId.contains(chapter.id),
                      lastReadAt: chapter.lastReadAt,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                  ),
                  itemCount: widget.chapters.length,
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
