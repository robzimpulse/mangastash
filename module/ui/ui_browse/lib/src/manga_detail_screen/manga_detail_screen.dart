import 'dart:ui';

import 'package:collection/collection.dart';
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

  void _onTapWebsite(BuildContext context, {String? url}) async {
    if (url == null || url.isEmpty) {
      context.showSnackBar(message: 'Could not launch source url');
      return;
    }

    _cubit(context).recrawl(url: url);
  }

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
            SliverAppBar(
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
                      _shareButton(context: context),
                    ],
                  ),
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Chapter'),
                  Tab(text: 'Description'),
                  Tab(text: 'Similar'),
                ],
              ),
            ),
          ],
          body: NextPageNotificationWidget(
            onLoadNextPage: () => _cubit(context).next(),
            child: RefreshIndicator(
              onRefresh: () => _cubit(context).init(useCache: false),
              child: _content(),
            ),
          ),
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
        if (state.chapters.isEmpty) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<DownloadOption>(
          icon: Icon(
            Icons.download,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
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
      buildWhen: (prev, curr) => prev.config != curr.config,
      builder: (context, state) => IconButton(
        icon: Icon(
          Icons.filter_list,
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
        onPressed: () async {
          final result = await widget.onTapSort?.call(state.config);
          if (!context.mounted) return;
          await _scrollController.animateTo(
            MediaQuery.of(context).size.height * 0.4,
            duration: const Duration(milliseconds: 200),
            curve: Curves.decelerate,
          );
          if (!context.mounted || result == null) return;
          _cubit(context).init(config: result);
        },
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

  Widget _manga() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoadingManga != curr.isLoadingManga,
        prev.isOnLibrary != curr.isOnLibrary,
        prev.manga != curr.manga,
        prev.errorManga != curr.errorManga,
      ].contains(true),
      builder: (context, state) {
        final error = state.errorManga;

        if (error != null) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                    ),
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
          );
        }

        return MangaDetailWidget(
          cacheManager: widget.cacheManager,
          description: state.manga?.description,
          tags: [...?state.manga?.tags?.map((e) => e.name).nonNulls],
          horizontalPadding: 12,
          isOnLibrary: state.isOnLibrary,
          onTapAddToLibrary: () => _cubit(context).addToLibrary(),
          onTapPrefetch: () => _cubit(context).prefetch(),
          onTapWebsite: () => _onTapWebsite(context, url: state.manga?.webUrl),
          onTapTag: (name) => _onTapTag(
            context,
            tag: state.manga?.tags?.firstWhereOrNull((e) => e.name == name),
          ),
          isLoadingManga: state.isLoadingManga,
          isLoadingChapters: state.isLoadingChapters,
        );
      },
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
                        .intersperse(_separator())
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

  Widget _content() {
    return CustomScrollView(
      slivers: [
        _manga(),
        _chapters(),
      ],
    );
  }

  Widget _separator() => const Divider(height: 1);
}
