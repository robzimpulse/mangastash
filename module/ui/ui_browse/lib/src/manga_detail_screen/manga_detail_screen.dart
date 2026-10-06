import 'dart:ui';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
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
    this.onTapTag,
    required this.imagesCacheManager,
    required this.logBox,
  });

  final ValueSetter<Tag>? onTapTag;

  final ValueSetter<Chapter>? onTapChapter;

  final ValueSetter<Manga>? onTapManga;

  final Future<MangaMenu?>? Function(Manga, bool)? onMangaMenu;

  final Future<ChapterConfig?> Function(ChapterConfig? value)? onTapSort;

  final ImagesCacheManager imagesCacheManager;

  final LogBox logBox;

  static Widget create({
    required ServiceLocator locator,
    String? source,
    String? mangaId,
    ValueSetter<Tag>? onTapTag,
    ValueSetter<Chapter>? onTapChapter,
    ValueSetter<Manga>? onTapManga,
    Future<MangaMenu?>? Function(Manga, bool)? onMangaMenu,
    Future<ChapterConfig?> Function(ChapterConfig? value)? onTapSort,
  }) {
    return BlocProvider(
      create: (context) {
        final ListenSettingDownloadedOnlyUseCase isDownloaded = locator();
        return MangaDetailScreenCubit(
          initialState: MangaDetailScreenState(
            mangaId: mangaId,
            source: source?.let(Sources.fromName),
            config: ChapterConfig(
              downloaded: isDownloaded.downloadedOnlyState.valueOrNull,
            ),
          ),
          getMangaUseCase: locator(),
          searchChapterUseCase: locator(),
          addToLibraryUseCase: locator(),
          removeFromLibraryUseCase: locator(),
          listenMangaFromLibraryUseCase: locator(),
          listenPrefetchUseCase: locator(),
          prefetchChapterUseCase: locator(),
          listenReadHistoryUseCase: locator(),
          listenSearchParameterUseCase: locator(),
          getAllChapterUseCase: locator(),
          searchMangaUseCase: locator(),
          recrawlUseCase: locator(),
          listenDownloadedChapterUseCase: locator(),
        )..init();
      },
      child: MangaDetailScreen(
        imagesCacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapManga: onTapManga,
        onMangaMenu: onMangaMenu,
        onTapSort: onTapSort,
        onTapTag: onTapTag,
        logBox: locator(),
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

  MangaDetailScreenCubit? _cubit(BuildContext context) {
    return context.mounted ? context.read() : null;
  }

  void _onTapRecrawl({required BuildContext context, required String url}) {
    _cubit(context)?.recrawl(context: context, url: url);
  }

  // [manga] targets the long-pressed similar manga instead of the one on
  // screen; null is the header popup's Download, which always means the manga
  // this screen was opened for.
  void _onTapDownload({
    required BuildContext context,
    required DownloadOption option,
    Manga? manga,
  }) async {
    final cubit = _cubit(context);
    if (cubit == null) return;
    // Both cubit methods return 0 for two opposite situations: the chapter
    // list has nothing left to queue, or their isPrefetchingAll guard
    // rejected this tap because a bulk run is already in flight. The popup
    // stays enabled during a run, so this handler — not the control — has to
    // say which one it is: reporting "Nothing to download" mid-run would be
    // false (#119).
    if (cubit.state.isPrefetchingAll) {
      context.showSnackBar(message: 'Download already in progress');
      return;
    }
    int enqueued;
    try {
      enqueued =
          manga == null
              ? await cubit.download(option: option)
              // The long-press menu offers no Unread entry and read history
              // is scoped to the manga on screen, so its download is always
              // All — see MangaDetailScreenCubit.downloadManga.
              : await cubit.downloadManga(manga: manga);
    } catch (e, s) {
      // Neither cubit method has a catch of its own, so without this the error
      // escapes the void async caller and the user gets no response at all —
      // spec §4 requires "abort + snackbar, enqueue nothing". The try also
      // wraps the enqueue calls and their state emits, not just the
      // chapter-list fetch, so the snackbar names the action that failed
      // rather than the fetch step it most often fails at. Strip the
      // "Exception: " noise so this reads like the sibling "Failed to add
      // manga: ..." wording in library_manga_screen.
      widget.logBox.log(
        'Download handler failed',
        error: e,
        stackTrace: s,
        extra: {
          'option': option.name,
          'targetMangaId':
              manga?.id ?? cubit.state.manga?.id ?? cubit.state.mangaId,
        },
        name: runtimeType.toString(),
      );
      if (!context.mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      context.showSnackBar(message: 'Failed to download: $message');
      return;
    }
    if (!context.mounted) return;
    if (enqueued == 0) {
      context.showSnackBar(message: 'Nothing to download');
    }
  }

  void _onTapFilter({
    required BuildContext context,
    required ChapterConfig config,
  }) async {
    final result = await widget.onTapSort?.call(config);
    if (!context.mounted || result == null) return;
    _cubit(context)?.initChapter(config: result);
  }

  void _onLongPressManga({
    required BuildContext context,
    required Manga manga,
    required bool isOnLibrary,
  }) async {
    final result = await widget.onMangaMenu?.call(manga, isOnLibrary);
    if (!context.mounted || result == null) return;
    switch (result) {
      case MangaMenu.download:
        // Routed through _onTapDownload so the long-press menu and the
        // header popup share one handler — including the empty-target
        // snackbar, so this entry point can't silently do nothing (#119).
        // The target travels with the call: this menu is only ever opened on
        // a similar-manga tile, and without the manga argument the handler
        // resolved the manga on screen instead (#119).
        _onTapDownload(
          context: context,
          option: DownloadOption.all,
          manga: manga,
        );
      case MangaMenu.library:
        _onTapAddToLibrary(context: context, manga: manga);
      case MangaMenu.prefetch:
        // This screen's prefetch is parameterless — it prefetches the manga
        // already in state, not the long-pressed similar-manga entry.
        //
        // Deliberately silent, unlike the download case above: prefetch() is
        // void and reports nothing back, so unlike download() there is no
        // return value for a handler to turn into feedback. Leaving it alone
        // keeps this case consistent with the bulk prefetch button, whose only
        // run signal is isPrefetchingAll — ListWidget uses it to null that
        // button's onPressed during a run, not to render a progress
        // indicator. Do not add a count here without first deciding what
        // prefetch() should report (#119).
        await _cubit(context)?.prefetch();
    }
  }

  void _onTapAddToLibrary({required BuildContext context, Manga? manga}) {
    if (manga == null) return;
    _cubit(context)?.addToLibrary(manga: manga);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, isInnerBoxScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  stretch: true,
                  pinned: true,
                  elevation: 0,
                  expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleAppBarBuilder(
                    builder: (context, progress) {
                      final theme = Theme.of(context);
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: kTextTabBarHeight,
                        ),
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
                              color: theme.appBarTheme.iconTheme?.color,
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
                      );
                    },
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
            ];
          },
          body: _content(),
        ),
      ),
    );
  }

  Widget _appBarBackground() {
    return _builder(
      buildWhen: (prev, curr) => prev.manga?.coverUrl != curr.manga?.coverUrl,
      builder: (context, state) {
        final url = state.manga?.coverUrl;

        Widget view;
        if (url == null) {
          view = const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          view = CachedNetworkImage(
            fit: BoxFit.cover,
            cacheManager: widget.imagesCacheManager,
            imageUrl: url,
            errorWidget: (context, url, error) {
              return ImageInfoWidget.error(url: url, error: error);
            },
            progressIndicatorBuilder: (context, url, progress) {
              return ImageInfoWidget.loading(
                url: url,
                progress: progress.progress,
              );
            },
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: view),
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
          onPressed: () => _onTapRecrawl(context: context, url: url),
        );
      },
    );
  }

  Widget _addToLibraryButton({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.manga != curr.manga,
          prev.isOnLibrary != curr.isOnLibrary,
          // Re-render while the toggle is in flight so the button can
          // disable and block a double-tap (#127).
          prev.pendingLibraryMangaIds != curr.pendingLibraryMangaIds,
        ].contains(true);
      },
      builder: (context, state) {
        if (state.manga == null) return const SizedBox.shrink();
        final isToggleInFlight = state.manga?.id != null &&
            state.pendingLibraryMangaIds.contains(state.manga?.id);
        return IconButton(
          icon: Icon(
            state.isOnLibrary ? Icons.favorite : Icons.favorite_outline,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          // Disabled while the toggle is executing — the cubit also
          // no-ops repeat calls as a second line of defense (#127).
          onPressed: isToggleInFlight
              ? null
              : () {
                  final manga = state.manga;
                  if (manga == null) return;
                  _cubit(context)?.addToLibrary(manga: manga);
                },
        );
      },
    );
  }

  Widget _title({required double progress}) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.isLoadingManga != curr.isLoadingManga,
          prev.manga?.title != curr.manga?.title,
        ].contains(true);
      },
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
          buildWhen: (prev, curr) {
            return [
              prev.mangaId != curr.mangaId,
              prev.isLoadingManga != curr.isLoadingManga,
              prev.errorChapters != curr.errorChapters,
              prev.isLoadingChapters != curr.isLoadingChapters,
              prev.filtered != curr.filtered,
              prev.totalChapter != curr.totalChapter,
              prev.hasNextPageChapter != curr.hasNextPageChapter,
              prev.prefetchedChapterIds != curr.prefetchedChapterIds,
              prev.downloadedChapterIds != curr.downloadedChapterIds,
              prev.config != curr.config,
              prev.isPrefetchingAll != curr.isPrefetchingAll,
            ].contains(true);
          },
          builder: (context, state) {
            return ListWidget(
              itemBuilder: (context, data) {
                return ChapterTileWidget.chapter(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onTap: () => widget.onTapChapter?.call(data),
                  onTapLongPress: () {
                    final chapterId = data.id;
                    if (chapterId == null) return;
                    _cubit(context)?.downloadChapter(chapterId: chapterId);
                  },
                  chapter: data,
                  opacity: data.lastReadAt != null ? 0.5 : 1,
                  isPrefetching: state.prefetchedChapterIds.contains(data.id),
                  isDownloaded: state.downloadedChapterIds.contains(data.id),
                  lastReadAt: data.lastReadAt,
                );
              },
              pageStorageKey: PageStorageKey('chapter-list-${state.mangaId}'),
              absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(
                context,
              ),
              onLoadNextPage: () => _cubit(context)?.nextChapter(),
              onRefresh: () async {
                await _cubit(context)?.initChapter(refresh: true);
              },
              onTapRecrawl: (url) => _onTapRecrawl(context: context, url: url),
              onTapDownload: (option) {
                _onTapDownload(context: context, option: option);
              },
              onTapFilter: () {
                _onTapFilter(context: context, config: state.config);
              },
              onTapPrefetch: () => _cubit(context)?.prefetch(),
              isPrefetchingAll: state.isPrefetchingAll,
              error: state.errorChapters,
              isLoading: state.isLoadingChapters || state.isLoadingManga,
              hasNext: state.hasNextPageChapter,
              data: state.filtered,
              total: state.totalChapter ?? 0,
            );
          },
        ),
        _builder(
          buildWhen: (prev, curr) {
            return [
              prev.manga != curr.manga,
              prev.isLoadingManga != curr.isLoadingManga,
            ].contains(true);
          },
          builder: (context, state) {
            return ChapterDescriptionWidget(
              absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(
                context,
              ),
              isLoading: state.isLoadingManga,
              tags: [...?state.manga?.tags],
              description: state.manga?.description,
              onTapTag: widget.onTapTag,
            );
          },
        ),
        _builder(
          buildWhen: (prev, curr) {
            return [
              prev.mangaId != curr.mangaId,
              prev.isLoadingManga != curr.isLoadingManga,
              prev.similarManga != curr.similarManga,
              prev.errorSimilarManga != curr.errorSimilarManga,
              prev.isLoadingSimilarManga != curr.isLoadingSimilarManga,
              prev.hasNextPageSimilarManga != curr.hasNextPageSimilarManga,
              prev.prefetchedMangaIds != curr.prefetchedMangaIds,
              prev.libraryMangaIds != curr.libraryMangaIds,
            ].contains(true);
          },
          builder: (context, state) {
            return GridWidget(
              itemBuilder: (context, data) {
                return MangaItemWidget(
                  manga: data,
                  cacheManager: widget.imagesCacheManager,
                  onTap: () => widget.onTapManga?.call(data),
                  onLongPress: () {
                    _onLongPressManga(
                      context: context,
                      manga: data,
                      isOnLibrary: state.libraryMangaIds.contains(data.id),
                    );
                  },
                  isOnLibrary: state.libraryMangaIds.contains(data.id),
                  isPrefetching: state.prefetchedMangaIds.contains(data.id),
                );
              },
              pageStorageKey: PageStorageKey('similar-manga-${state.mangaId}'),
              absorber: NestedScrollView.sliverOverlapAbsorberHandleFor(
                context,
              ),
              onRefresh: () async {
                await _cubit(context)?.initSimilarManga(refresh: true);
              },
              onLoadNextPage: () => _cubit(context)?.nextSimilarManga(),
              onTapRecrawl: (url) => _onTapRecrawl(context: context, url: url),
              error: state.errorSimilarManga,
              isLoading: state.isLoadingSimilarManga || state.isLoadingManga,
              hasNext: state.hasNextPageSimilarManga,
              data: state.similarManga,
            );
          },
        ),
      ],
    );
  }
}
