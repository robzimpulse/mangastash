import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';

import '../manga_detail_screen_state.dart';

class ChapterListWidget extends StatelessWidget {
  const ChapterListWidget({
    super.key,
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
  Widget build(BuildContext context) {
    final absorber = this.absorber;
    final onRefresh = this.onRefresh;
    final error = this.error;

    Widget view = CustomScrollView(
      slivers: [
        if (absorber != null) SliverOverlapInjector(handle: absorber),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: isLoading ? 12 : 0),
                  child: Row(
                    children: [
                      ShimmerLoading.multiline(
                        isLoading: isLoading,
                        width: 50,
                        height: 15,
                        lines: 1,
                        child: Text(
                          '$total Chapters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Spacer(),
                      ShimmerLoading.multiline(
                        isLoading: isLoading,
                        width: 32,
                        height: 32,
                        lines: 1,
                        child: PopupMenuButton<DownloadOption>(
                          icon: const Icon(Icons.download),
                          onSelected: (value) => onTapDownload?.call(value),
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
                      if (isLoading) const SizedBox(width: 4),
                      ShimmerLoading.multiline(
                        isLoading: isLoading,
                        width: 32,
                        height: 32,
                        lines: 1,
                        child: IconButton(
                          icon: const Icon(Icons.cloud_download),
                          onPressed: () => onTapPrefetch?.call(),
                        ),
                      ),
                      if (isLoading) const SizedBox(width: 4),
                      ShimmerLoading.multiline(
                        isLoading: isLoading,
                        width: 32,
                        height: 32,
                        lines: 1,
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () => onTapFilter?.call(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
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
                              onPressed: () => onTapRecrawl?.call(error.url),
                              child: const Text('Open Debug Browser'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              ] else if (chapters.isEmpty) ...[
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
                    final chapter = chapters.elementAtOrNull(index);
                    if (chapter == null) return null;
                    return ChapterTileWidget(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onTap: () => onTapChapter?.call(chapter),
                      opacity: chapter.lastReadAt != null ? 0.5 : 1,
                      title: [
                        'Chapter ${chapter.chapter}',
                        chapter.title,
                      ].nonNulls.join(' - '),
                      language: Language.fromCode(chapter.translatedLanguage),
                      uploadedAt: chapter.readableAt,
                      groups: chapter.scanlationGroup,
                      isPrefetching: prefetchedChapterId.contains(chapter.id),
                      lastReadAt: chapter.lastReadAt,
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                  ),
                  itemCount: chapters.length,
                ),
                if (hasNext)
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
      onLoadNextPage: onLoadNextPage,
      child: (absorber != null && onRefresh != null)
          ? ListenableBuilder(
              listenable: absorber,
              builder: (context, child) => RefreshIndicator(
                onRefresh: onRefresh,
                edgeOffset: absorber.layoutExtent ?? 0,
                child: child ?? const SizedBox(),
              ),
              child: view,
            )
          : view,
    );
  }
}
