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
import 'widgets/manga_detail_app_bar_widget.dart';

class MangaDetailScreen extends StatefulWidget {
  const MangaDetailScreen({
    super.key,
    this.onTapChapter,
    this.onTapManga,
    this.onMangaMenu,
    this.onTapSort,
    required this.cacheManager,
  });

  final ValueSetter<Chapter>? onTapChapter;

  final ValueSetter<Manga>? onTapManga;

  final Future<MangaMenu?>? Function(Manga, bool)? onMangaMenu;

  final Future<ChapterConfig?> Function(ChapterConfig? value)? onTapSort;

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
    String? source,
    String? mangaId,
    ValueSetter<Chapter>? onTapChapter,
    ValueSetter<Manga>? onTapManga,
    Future<MangaMenu?>? Function(Manga, bool)? onMangaMenu,
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
        searchMangaUseCase: locator(),
      )..init(),
      child: MangaDetailScreen(
        cacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapManga: onTapManga,
        onMangaMenu: onMangaMenu,
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
    _cubit(context).initChapter(config: result);
  }

  void _onLongPressManga(
    BuildContext context,
    Manga manga,
    bool isOnLibrary,
  ) async {
    final result = await widget.onMangaMenu?.call(manga, isOnLibrary);
    if (!context.mounted || result == null) return;
    switch (result) {
      case MangaMenu.download:
      // TODO: download
      // _cubit(context).download(manga: manga);
      case MangaMenu.library:
        _onTapAddToLibrary(context, manga);
      case MangaMenu.prefetch:
      // TODO: prefetch
      // _cubit(context).prefetch(manga: manga);
    }
  }

  void _onTapAddToLibrary(BuildContext context, Manga? manga) {
    if (manga == null) return;
    _cubit(context).addToLibrary(manga: manga);
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
          onPressed: () {
            final manga = state.manga;
            if (manga == null) return;
            _cubit(context).addToLibrary(manga: manga);
          },
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
            prev.mangaId != curr.mangaId,
            prev.isLoadingManga != curr.isLoadingManga,
            prev.errorChapters != curr.errorChapters,
            prev.isLoadingChapters != curr.isLoadingChapters,
            prev.filtered != curr.filtered,
            prev.totalChapter != curr.totalChapter,
            prev.hasNextPageChapter != curr.hasNextPageChapter,
            prev.prefetchedChapterId != curr.prefetchedChapterId,
            prev.config != curr.config,
          ].contains(true),
          builder: (context, state) => ChapterListWidget(
            pageStorageKey: PageStorageKey('chapter-list-${state.mangaId}'),
            absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            onLoadNextPage: () => _cubit(context).nextChapter(),
            onRefresh: () => _cubit(context).initChapter(useCache: false),
            onTapRecrawl: (url) => _cubit(context).recrawl(url: url),
            onTapChapter: (chapter) => widget.onTapChapter?.call(chapter),
            onTapDownload: (option) => _onTapDownload(context, option),
            onTapFilter: () => _onTapFilter(context, state.config),
            onTapPrefetch: () => _cubit(context).prefetch(),
            prefetchedChapterId: state.prefetchedChapterId,
            error: state.errorChapters,
            isLoading: state.isLoadingChapters || state.isLoadingManga,
            hasNext: state.hasNextPageChapter,
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
            prev.mangaId != curr.mangaId,
            prev.isLoadingManga != curr.isLoadingManga,
            prev.similarManga != curr.similarManga,
            prev.errorSimilarManga != curr.errorSimilarManga,
            prev.isLoadingSimilarManga != curr.isLoadingSimilarManga,
            prev.hasNextPageSimilarManga != curr.hasNextPageSimilarManga,
            prev.prefetchedMangaId != curr.prefetchedMangaId,
            prev.libraryMangaId != curr.libraryMangaId,
          ].contains(true),
          builder: (context, state) => MangaGridWidget(
            pageStorageKey: PageStorageKey('similar-manga-${state.mangaId}'),
            absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            onRefresh: () => _cubit(context).initSimilarManga(useCache: false),
            onLoadNextPage: () => _cubit(context).nextSimilarManga(
              useCache: false,
            ),
            onTapManga: (manga) => widget.onTapManga?.call(manga),
            onLongPressManga: (manga) => _onLongPressManga(
              context,
              manga,
              state.libraryMangaId.contains(manga.id),
            ),
            onTapRecrawl: (url) => _cubit(context).recrawl(url: url),
            error: state.errorSimilarManga,
            isLoading: state.isLoadingSimilarManga || state.isLoadingManga,
            hasNext: state.hasNextPageSimilarManga,
            mangas: state.similarManga,
            prefetchedMangaId: state.prefetchedMangaId,
            cacheManager: widget.cacheManager,
            libraryMangaId: state.libraryMangaId,
          ),
        ),
      ],
    );
  }
}
