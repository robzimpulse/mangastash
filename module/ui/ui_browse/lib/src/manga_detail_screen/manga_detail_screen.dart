import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_detail_screen_cubit.dart';
import 'manga_detail_screen_state.dart';
import 'widgets/chapter_description_widget.dart';
import 'widgets/chapter_list_widget.dart';
import 'widgets/manga_grid_widget.dart';

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
          source: source?.let((e) => SourceEnum.fromValue(name: e)),
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

  // void _onTapTag(BuildContext context, {Tag? tag}) {
  //   // TODO: implement this
  //   return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  // }

  void _onTapDownload(BuildContext context, DownloadOption option) async {
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapFilter(BuildContext context, ChapterConfig config) async {
    final result = await widget.onTapSort?.call(config);
    if (!context.mounted || result == null) return;
    _cubit(context).init(config: result);
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
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(
                            (lerpDouble(200, 0, progress) ?? 0.0).toInt(),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: BackButton(
                          color: Theme.of(context).appBarTheme.iconTheme?.color,
                        ),
                      ),
                      title: _title(progress: progress),
                      actionsDecoration: BoxDecoration(
                        color: Colors.grey.withAlpha(
                          (lerpDouble(200, 0, progress) ?? 0.0).toInt(),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      actions: [
                        _addToLibraryButton(context: context),
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
          body: _content(),
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

  Widget _addToLibraryButton({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.manga != curr.manga,
        prev.isOnLibrary != curr.isOnLibrary,
      ].contains(true),
      builder: (context, state) {
        if (state.manga == null) return const SizedBox.shrink();
        return IconButton(
          icon: Icon(
            state.isOnLibrary ? Icons.favorite : Icons.favorite_outline,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => _cubit(context).addToLibrary(),
        );
      },
    );
  }

  Widget _title({required double progress}) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoadingManga != curr.isLoadingManga,
        prev.manga?.title != curr.manga?.title,
      ].contains(true),
      builder: (context, state) {
        final theme = Theme.of(context);

        return Container(
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.appBarTheme.iconTheme?.color,
                      fontSize: lerpDouble(
                        theme.textTheme.titleLarge?.fontSize ?? 0,
                        theme.textTheme.titleSmall?.fontSize ?? 0,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.appBarTheme.iconTheme?.color,
                      fontSize: lerpDouble(
                        theme.textTheme.labelSmall?.fontSize ?? 0,
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
        );
      },
    );
  }

  Widget _content() {
    return TabBarView(
      children: [
        _builder(
          buildWhen: (prev, curr) => [
            prev.errorChapters != curr.errorChapters,
            prev.isLoadingChapters != curr.isLoadingChapters,
            prev.filtered != curr.filtered,
            prev.totalChapter != curr.totalChapter,
            prev.hasNextPage != curr.hasNextPage,
            prev.prefetchedChapterId != curr.prefetchedChapterId,
            prev.config != curr.config,
          ].contains(true),
          builder: (context, state) => ChapterListWidget(
            absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            onLoadNextPage: () => _cubit(context).next(),
            onRefresh: () => _cubit(context).init(useCache: false),
            onTapRecrawl: (url) => _cubit(context).recrawl(url: url),
            onTapChapter: (chapter) => widget.onTapChapter?.call(chapter),
            onTapDownload: (option) => _onTapDownload(context, option),
            onTapFilter: () => _onTapFilter(context, state.config),
            onTapPrefetch: () => _cubit(context).prefetch(),
            prefetchedChapterId: state.prefetchedChapterId,
            error: state.errorChapters,
            isLoading: state.isLoadingChapters,
            hasNext: state.hasNextPage,
            chapters: state.filtered,
            total: state.totalChapter ?? 0,
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.manga != curr.manga,
            prev.isLoadingManga != curr.isLoadingManga,
          ].contains(true),
          builder: (context, state) => ChapterDescriptionWidget(
            absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            isLoading: state.isLoadingManga,
            tags: [...?state.manga?.tags],
            description: state.manga?.description,
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.manga != curr.manga,
            prev.isLoadingManga != curr.isLoadingManga,
          ].contains(true),
          builder: (context, state) => MangaGridWidget(
            absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            onRefresh: () async => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
            onLoadNextPage: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
            hasNextPage: false,
            builder: (context, index) => LayoutBuilder(
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
        ),
      ],
    );
  }
}
