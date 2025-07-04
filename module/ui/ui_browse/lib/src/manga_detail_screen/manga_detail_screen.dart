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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, isInnerBoxScrolled) => [
          SliverAppBar(
            stretch: true,
            pinned: true,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleAppBarBuilder(
              builder: (context, progress) => MangaDetailAppBarWidget(
                progress: progress,
                background: _appBarBackground(),
                leading: BackButton(
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
                title: _title(context: context, progress: progress),
                actions: [
                  _downloadButton(),
                  _filterButton(),
                  _shareButton(context: context),
                ],
              ),
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
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoadingManga != curr.isLoadingManga,
        prev.manga?.title != curr.manga?.title,
      ].contains(true),
      builder: (context, state) => ShimmerLoading.multiline(
        isLoading: state.isLoadingManga,
        width: 100,
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
              Theme.of(context).textTheme.headlineMedium?.fontSize ?? 0,
              Theme.of(context).textTheme.titleMedium?.fontSize ?? 0,
              progress,
            ),
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
          coverUrl: state.manga?.coverUrl,
          title: state.manga?.title,
          author: state.manga?.author,
          status: state.manga?.status,
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
      ].contains(true),
      builder: (context, state) {
        final error = state.errorChapters;
        if (error != null) return _errorChapter(context: context, error: error);
        if (state.isLoadingChapters) return _loadingChapter();
        if (state.filtered.isEmpty) return _emptyChapter();

        return MultiSliver(
          children: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Row(
                  children: [
                    Text(
                      '${state.totalChapter} Chapters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: MultiSliver(
                children: [
                  ...state.filtered
                      .map((e) => _chapterItem(chapter: e))
                      .intersperse(_separator())
                      .map((e) => SliverToBoxAdapter(child: e)),
                ],
              ),
            ),
          ],
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

  Widget _emptyChapter() {
    return MultiSliver(
      children: const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No Chapter',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingChapter() {
    return MultiSliver(
      children: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                ShimmerLoading.multiline(
                  isLoading: true,
                  width: 50,
                  height: 15,
                  lines: 1,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => index.isOdd
                  ? const SizedBox(height: 4)
                  : ShimmerLoading.multiline(
                      isLoading: true,
                      width: double.infinity,
                      height: 15,
                      lines: 3,
                    ),
              childCount: (50 * 2) - 1,
              semanticIndexCallback: (Widget _, int index) {
                return index.isEven ? index ~/ 2 : null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorChapter({
    required BuildContext context,
    required Exception error,
  }) {
    return MultiSliver(
      children: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  if (error is FailedParsingHtmlException) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _cubit(context).recrawl(url: error.url),
                      child: const Text('Open Debug Browser'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _content() {
    return CustomScrollView(
      slivers: [
        _manga(),
        _chapters(),
        SliverToBoxAdapter(
          child: _builder(
            buildWhen: (prev, curr) => prev.hasNextPage != curr.hasNextPage,
            builder: (context, state) => state.hasNextPage
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _separator() => const Divider(height: 1);
}
