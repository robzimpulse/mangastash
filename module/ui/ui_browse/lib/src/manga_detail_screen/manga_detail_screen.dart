import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
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
    this.cacheManager,
    required this.launchUrlUseCase,
  });

  final Function(String?, List<String>?)? onTapChapter;

  final Future<MangaChapterConfig?> Function(MangaChapterConfig?)? onTapSort;

  final LaunchUrlUseCase launchUrlUseCase;

  final BaseCacheManager? cacheManager;

  static Widget create({
    required ServiceLocator locator,
    required MangaSourceEnum? sourceEnum,
    required String? mangaId,
    Manga? manga,
    Function(String?, List<String>?)? onTapChapter,
    Future<MangaChapterConfig?> Function(MangaChapterConfig?)? onTapSort,
  }) {
    return BlocProvider(
      create: (context) => MangaDetailScreenCubit(
        initialState: MangaDetailScreenState(
          manga: manga,
          mangaId: mangaId,
          sourceEnum: sourceEnum,
        ),
        getMangaUseCase: locator(),
        searchChapterUseCase: locator(),
        addToLibraryUseCase: locator(),
        listenAuth: locator(),
        removeFromLibraryUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
        downloadChapterUseCase: locator(),
        listenDownloadProgressUseCase: locator(),
        crawlUrlUseCase: locator(),
      )..init(),
      child: MangaDetailScreen(
        cacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapSort: onTapSort,
        launchUrlUseCase: locator(),
      ),
    );
  }

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  late final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) => _cubit(context).next(),
  );

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

  void _onTapWebsite(BuildContext context, MangaDetailScreenState state) async {
    final url = state.manga?.webUrl;

    if (url == null || url.isEmpty) {
      context.showSnackBar(message: 'Could not launch source url');
      return;
    }

    final result = await widget.launchUrlUseCase.launch(
      url: url,
      mode: LaunchMode.externalApplication,
    );

    if (result || !context.mounted) return;
    context.showSnackBar(message: 'Could not launch $url');
  }

  void _onTapTag(BuildContext context, {MangaTag? tag}) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapDownload(
    BuildContext context,
    DownloadOption option,
  ) async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.notification,
    ].request();

    if (!context.mounted) return;

    switch (option) {
      case DownloadOption.all:
        await _cubit(context).downloadAllChapter();
        if (!context.mounted) return;
        context.showSnackBar(message: 'Downloading All Chapter');
        break;
      // case DownloadOption.next:
      // // TODO: Handle this case.
      // case DownloadOption.next5:
      // // TODO: Handle this case.
      // case DownloadOption.next10:
      // // TODO: Handle this case.
      // case DownloadOption.custom:
      // // TODO: Handle this case.
      // case DownloadOption.unread:
      // // TODO: Handle this case.
      default:
        // TODO: implement this
        context.showSnackBar(
          message: '🚧🚧🚧 Under Construction $option 🚧🚧🚧',
        );
    }
  }

  void _onTapDownloadChapter(
    BuildContext context,
    MangaChapter? chapter,
  ) async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.notification,
    ].request();

    if (!context.mounted || chapter == null) return;
    _cubit(context).downloadChapter(chapter: chapter);
  }

  void _onTapMenuChapter(BuildContext context, MangaChapter? chapter) {
    // TODO: implement this
    context.showSnackBar(message: '🚧🚧🚧 Under Construction $chapter 🚧🚧🚧');
  }

  void _onTapShare(BuildContext context) {
    // TODO: implement this
    context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapAddToLibrary(
    BuildContext context,
    MangaDetailScreenState state,
  ) async {
    final status = state.authState?.status;
    if (status != AuthStatus.loggedIn) {
      final result = await context.push<AuthState>(AuthRoutePath.login);
      if (result == null || !context.mounted) return;
      _cubit(context).addToLibrary(user: result.user);
      return;
    }

    _cubit(context).addToLibrary(user: state.authState?.user);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: PrimaryScrollController(
        controller: _scrollController,
        child: NestedScrollView(
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
                  // title: Container(color: Colors.red),
                  title: _title(progress: progress),
                  actions: [
                    _downloadButton(),
                    _filterButton(),
                    _shareButton(context: context),
                  ],
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            onRefresh: () => _cubit(context).init(),
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
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              cacheManager: widget.cacheManager,
              imageUrl: state.manga?.coverUrl ?? '',
              errorWidget: (context, url, error) => const Icon(Icons.error),
              progressIndicatorBuilder: (context, url, progress) {
                return Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                );
              },
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
      builder: (context, state) => state.chapters?.isNotEmpty == true
          ? PopupMenuButton<DownloadOption>(
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
            )
          : const SizedBox.shrink(),
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
          if (!context.mounted || result == null) return;
          _cubit(context).updateMangaConfig(result);
        },
      ),
    );
  }

  Widget _shareButton({required BuildContext context}) {
    return IconButton(
      icon: Icon(
        Icons.share,
        color: Theme.of(context).appBarTheme.iconTheme?.color,
      ),
      onPressed: () => _onTapShare(context),
    );
  }

  Widget _title({required double progress}) {
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _cubit(context).recrawl(url: error.url),
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
          tags: state.manga?.tagsName,
          horizontalPadding: 12,
          isOnLibrary: state.isOnLibrary,
          onTapAddToLibrary: () => _onTapAddToLibrary(context, state),
          onTapWebsite: () => _onTapWebsite(context, state),
          onTapTag: (name) => _onTapTag(
            context,
            tag: state.manga?.mapTagsByName[name],
          ),
          isLoading: state.isLoadingManga,
        );
      },
    );
  }

  Widget _chapters() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.errorChapters != curr.errorChapters,
        prev.isLoadingChapters != curr.isLoadingChapters,
        prev.chaptersKey != curr.chaptersKey,
      ].contains(true),
      builder: (context, state) {
        final error = state.errorChapters;
        if (error != null) return _errorChapter(context: context, error: error);
        if (state.isLoadingChapters) return _loadingChapter();

        final chapters = state.chaptersKey;
        if (chapters.isEmpty) return _emptyChapter();

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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: (chapters.length * 2) - 1,
                  semanticIndexCallback: (Widget _, int index) {
                    return index.isEven ? index ~/ 2 : null;
                  },
                  (context, index) {
                    final int itemIndex = index ~/ 2;
                    final valueIndex = chapters.elementAtOrNull(itemIndex);
                    final value = state.processedChapters[valueIndex];
                    final key = DownloadChapterKey.create(
                      manga: state.manga,
                      chapter: value,
                    );

                    return index.isOdd
                        ? _separator()
                        : _chapterItem(key: key, value: value);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chapterItem({required DownloadChapterKey key, MangaChapter? value}) {
    if (value == null) return const SizedBox.shrink();
    return _builder(
      buildWhen: (prev, curr) => prev.progress?[key] != curr.progress?[key],
      builder: (context, state) => MangaChapterTileWidget(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        onTap: () => widget.onTapChapter?.call(value.id, state.chapterIds),
        onTapDownload: () => _onTapDownloadChapter(context, value),
        onLongPress: () => _onTapMenuChapter(context, value),
        title: [
          'Chapter ${value.chapter}',
          value.title,
        ].whereNotNull().join(' - '),
        language: Language.fromCode(value.translatedLanguage),
        uploadedAt: value.readableAt?.asDateTime,
        groups: value.scanlationGroup,
        downloadProgress: state.progress?[key]?.progress.toDouble() ?? 0.0,
      ),
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        return _scrollController.onScrollNotification(
          context,
          scrollNotification,
        );
      },
      child: CustomScrollView(
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
      ),
    );
  }

  Widget _separator() => const Divider(height: 1);
}
