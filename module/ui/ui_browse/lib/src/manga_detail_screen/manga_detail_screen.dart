import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_detail_screen_cubit.dart';
import 'manga_detail_screen_state.dart';

class MangaDetailScreen extends StatefulWidget {
  const MangaDetailScreen({
    super.key,
    this.onTapChapter,
    this.onTapSort,
    required this.cacheManager,
  });

  final ValueSetter<Chapter>? onTapChapter;

  final Future<ChapterConfig?> Function(ChapterConfig? value)? onTapSort;

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
    String? source,
    String? mangaId,
    ValueSetter<Chapter>? onTapChapter,
    Future<ChapterConfig?> Function(ChapterConfig? value)? onTapSort,
  }) {
    return BlocProvider(
      create: (context) => MangaDetailScreenCubit(
        initialState: MangaDetailScreenState(
          mangaId: mangaId,
          source: Source.fromValue(source),
        ),
        getMangaUseCase: locator(),
        searchChapterUseCase: locator(),
        addToLibraryUseCase: locator(),
        removeFromLibraryUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
        crawlUrlUseCase: locator(),
        listenPrefetchUseCase: locator(),
        prefetchChapterUseCase: locator(),
        listenReadHistoryUseCase: locator(),
        updateChapterLastReadAtUseCase: locator(),
        listenSearchParameterUseCase: locator(),
        getAllChapterUseCase: locator(),
      )..init(),
      child: MangaDetailScreen(
        cacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapSort: onTapSort,
      ),
    );
  }

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaDetailScreenState> builder,
    BlocBuilderCondition<MangaDetailScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaDetailScreenCubit, MangaDetailScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  MangaDetailScreenCubit _cubit(BuildContext context) => context.read();

  void _onTapTag(BuildContext context, {Tag? tag}) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapDownload(
    BuildContext context,
    DownloadOption option,
  ) async {
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, isInnerBoxScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                stretch: true,
                pinned: true,
                elevation: 0,
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleAppBarBuilder(
                  builder: (context, progress) => Padding(
                    padding: const EdgeInsets.only(bottom: kTextTabBarHeight),
                    child: MangaDetailAppBarWidget(
                      progress: progress,
                      background: _appBarBackground(),
                      leading: BackButton(
                        color: Theme.of(context).appBarTheme.iconTheme?.color,
                      ),
                      title: _title(context: context, progress: progress),
                      actions: [
                        _websiteButton(context: context),
                        _shareButton(context: context),
                      ],
                    ),
                  ),
                ),
                bottom: DecoratedPreferredSizeWidget(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Chapter'),
                      Tab(text: 'Description'),
                      Tab(text: 'Similar'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Builder(builder: (context) => _content(context: context)),
        ),
      ),
    );
  }

  Widget _appBarBackground() {
    return _builder(
      buildWhen: (prev, curr) => prev.manga?.coverUrl != curr.manga?.coverUrl,
      builder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CachedNetworkImageWidget(
              fit: BoxFit.cover,
              cacheManager: widget.cacheManager,
              imageUrl: state.manga?.coverUrl ?? '',
              errorBuilder: (context, error, _) => const Icon(Icons.error),
              progressBuilder: (context, progress) => Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadButton() {
    return _builder(
      buildWhen: (prev, curr) => prev.chapters != curr.chapters,
      builder: (context, state) {
        if (state.chapters.isEmpty) return const SizedBox.shrink();

        return PopupMenuButton<DownloadOption>(
          icon: const Icon(Icons.download),
          onSelected: (value) => _onTapDownload(context, value),
          itemBuilder: (context) => [
            ...DownloadOption.values.map(
              (e) => PopupMenuItem<DownloadOption>(
                value: e,
                child: Text(e.value),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterButton() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.config != curr.config,
        prev.chapters != curr.chapters,
      ].contains(true),
      builder: (context, state) {
        if (state.chapters.isEmpty) return const SizedBox.shrink();

        return IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            final result = await widget.onTapSort?.call(state.config);
            if (!context.mounted || result == null) return;
            _cubit(context).init(config: result);
          },
        );
      },
    );
  }

  Widget _shareButton({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.manga != curr.manga,
      builder: (context, state) {
        final uri = state.manga?.webUrl?.let((url) => Uri.tryParse(url));

        if (uri == null) return const SizedBox.shrink();

        return IconButton(
          icon: Icon(
            Icons.share,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => SharePlus.instance.share(ShareParams(uri: uri)),
        );
      },
    );
  }

  Widget _websiteButton({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.manga != curr.manga,
      builder: (context, state) {
        final url = state.manga?.webUrl;

        if (url == null) return const SizedBox.shrink();

        return IconButton(
          icon: Icon(
            Icons.web,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => _cubit(context).recrawl(url: url),
        );
      },
    );
  }

  Widget _title({required BuildContext context, required double progress}) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium;

    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoadingManga != curr.isLoadingManga,
        prev.manga?.title != curr.manga?.title,
      ].contains(true),
      builder: (context, state) => Container(
        alignment: Alignment.lerp(
          Alignment.bottomCenter,
          Alignment.centerLeft,
          progress,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(
              (lerpDouble(50, 0, progress) ?? 0.0).toInt(),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(lerpDouble(16, 0, progress) ?? 0),
            ),
          ),
          padding: EdgeInsets.lerp(
            const EdgeInsets.all(8),
            EdgeInsets.zero,
            progress,
          ),
          margin: EdgeInsets.only(bottom: lerpDouble(16, 0, progress) ?? 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerLoading.multiline(
                isLoading: state.isLoadingManga,
                width: lerpDouble(300, 100, progress) ?? 300,
                height: 20,
                lines: 1,
                child: Text(
                  state.manga?.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle?.copyWith(
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                    fontSize: lerpDouble(
                      Theme.of(context).textTheme.titleLarge?.fontSize ?? 0,
                      Theme.of(context).textTheme.titleSmall?.fontSize ?? 0,
                      progress,
                    ),
                  ),
                ),
              ),
              SizedBox(height: lerpDouble(8, 0, progress) ?? 8),
              ShimmerLoading.multiline(
                isLoading: state.isLoadingManga,
                width: lerpDouble(300, 100, progress) ?? 300,
                height: lerpDouble(20, 0, progress) ?? 20,
                lines: 1,
                child: Text(
                  [
                    state.manga?.source,
                    state.manga?.status,
                    state.manga?.author,
                  ].nonNulls.join(' - '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle?.copyWith(
                    color: theme.appBarTheme.iconTheme?.color,
                    fontSize: lerpDouble(
                      Theme.of(context).textTheme.labelSmall?.fontSize ?? 0,
                      0,
                      progress,
                    ),
                    // fontSize: theme.textTheme.labelSmall?.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chapters() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.errorChapters != curr.errorChapters,
        prev.isLoadingChapters != curr.isLoadingChapters,
        prev.filtered != curr.filtered,
        prev.totalChapter != curr.totalChapter,
        prev.hasNextPage != curr.hasNextPage,
      ].contains(true),
      builder: (context, state) {
        final error = state.errorChapters;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      ShimmerLoading.multiline(
                        isLoading: state.isLoadingChapters,
                        width: 50,
                        height: 15,
                        lines: 1,
                        child: Text(
                          '${state.totalChapter} Chapters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Spacer(),
                      _downloadButton(),
                      _filterButton(),
                    ],
                  ),
                ),
              ),
              if (state.isLoadingChapters)
                MultiSliver(
                  children: [
                    ...List.generate(20, (e) => e)
                        .map<Widget>(
                          (e) => ShimmerLoading.multiline(
                            isLoading: true,
                            width: double.infinity,
                            height: 15,
                            lines: 3,
                          ),
                        )
                        .intersperse(const SizedBox(height: 4))
                        .map((e) => SliverToBoxAdapter(child: e)),
                  ],
                )
              else if (state.filtered.isEmpty)
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
                              onPressed: () => _cubit(context).recrawl(
                                url: error.url,
                              ),
                              child: const Text('Open Debug Browser'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                MultiSliver(
                  children: [
                    ...state.filtered
                        .map((e) => _chapterItem(chapter: e))
                        .intersperse(const Divider(height: 1))
                        .map((e) => SliverToBoxAdapter(child: e)),
                    if (state.hasNextPage)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _chapterItem({required Chapter chapter}) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.prefetchedChapterId != curr.prefetchedChapterId,
        prev.histories[chapter.id] != curr.histories[chapter.id],
      ].contains(true),
      builder: (context, state) {
        final lastReadAt = chapter.lastReadAt.orNull(
          state.histories[chapter.id]?.lastReadAt,
        );
        return ChapterTileWidget(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onTap: () => widget.onTapChapter?.call(chapter),
          opacity: lastReadAt != null ? 0.5 : 1,
          title: [
            'Chapter ${chapter.chapter}',
            chapter.title,
          ].nonNulls.join(' - '),
          language: Language.fromCode(chapter.translatedLanguage),
          uploadedAt: chapter.readableAt,
          groups: chapter.scanlationGroup,
          isPrefetching: state.prefetchedChapterId.contains(chapter.id),
          lastReadAt: lastReadAt,
        );
      },
    );
  }

  Widget _content({required BuildContext context}) {
    final absorber = NestedScrollView.sliverOverlapAbsorberHandleFor(context);

    return TabBarView(
      children: [
        NextPageNotificationWidget(
          onLoadNextPage: () => _cubit(context).next(),
          child: ListenableBuilder(
            listenable: absorber,
            builder: (context, child) => RefreshIndicator(
              edgeOffset: absorber.layoutExtent ?? 0,
              child: child ?? const SizedBox.shrink(),
              onRefresh: () => _cubit(context).init(useCache: false),
            ),
            child: CustomScrollView(
              slivers: [
                SliverOverlapInjector(handle: absorber),
                _chapters(),
              ],
            ),
          ),
        ),
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: MultiSliver(
                children: [
                  SliverOverlapInjector(handle: absorber),
                  SliverToBoxAdapter(
                    child: _builder(
                      buildWhen: (prev, curr) => [
                        prev.manga != curr.manga,
                        prev.isLoadingManga != curr.isLoadingManga,
                        prev.isLoadingChapters != curr.isLoadingChapters,
                        prev.isOnLibrary != curr.isOnLibrary,
                      ].contains(true),
                      builder: (context, state) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                            onTap: () => _cubit(context).addToLibrary(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShimmerLoading.box(
                                  isLoading: state.isLoadingManga,
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    state.isOnLibrary
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ShimmerLoading.multiline(
                                  isLoading: state.isLoadingManga,
                                  lines: 1,
                                  width: 50,
                                  height: 15,
                                  child: const Text('Library'),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _cubit(context).prefetch(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShimmerLoading.box(
                                  isLoading: [
                                    state.isLoadingManga,
                                    state.isLoadingChapters,
                                  ].every((e) => e),
                                  width: 50,
                                  height: 50,
                                  child: const Icon(Icons.cloud_download),
                                ),
                                const SizedBox(height: 2),
                                ShimmerLoading.multiline(
                                  isLoading: [
                                    state.isLoadingManga,
                                    state.isLoadingChapters,
                                  ].every((e) => e),
                                  lines: 1,
                                  width: 50,
                                  height: 15,
                                  child: const Text('Prefetch'),
                                ),
                              ],
                            ),
                          ),
                        ].intersperse(const SizedBox.shrink()).toList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _builder(
                      buildWhen: (prev, curr) => [
                        prev.manga != curr.manga,
                        prev.isLoadingManga != curr.isLoadingManga,
                      ].contains(true),
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag in [...?state.manga?.tags])
                                ShimmerLoading.box(
                                  isLoading: state.isLoadingManga,
                                  width: 50,
                                  height: 30,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 30,
                                    ),
                                    child: OutlinedButton(
                                      child: Text(tag.name ?? ''),
                                      onPressed: () => _onTapTag(
                                        context,
                                        tag: tag,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: _builder(
                      buildWhen: (prev, curr) => [
                        prev.manga != curr.manga,
                        prev.isLoadingManga != curr.isLoadingManga,
                      ].contains(true),
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ShimmerLoading.multiline(
                            isLoading: state.isLoadingManga,
                            width: double.infinity,
                            height: 15,
                            lines: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(state.manga?.description ?? ''),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        CustomScrollView(
          slivers: [
            SliverOverlapInjector(handle: absorber),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🚧🚧🚧 Under Construction 🚧🚧🚧',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
