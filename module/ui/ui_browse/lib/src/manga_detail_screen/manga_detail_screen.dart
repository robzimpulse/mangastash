import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
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
    required MangaSourceEnum? source,
    required String? mangaId,
    Function(String?, List<String>?)? onTapChapter,
    Future<MangaChapterConfig?> Function(MangaChapterConfig?)? onTapSort,
  }) {
    return BlocProvider(
      create: (context) => MangaDetailScreenCubit(
        initialState: MangaDetailScreenState(
          mangaId: mangaId,
          source: source,
        ),
        getMangaUseCase: locator(),
        getListChapterUseCase: locator(),
        getMangaSourceUseCase: locator(),
        addToLibraryUseCase: locator(),
        listenAuth: locator(),
        removeFromLibraryUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
        downloadChapterUseCase: locator(),
        listenDownloadProgressUseCase: locator(),
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

  FlexibleSpaceBarSettings? _flexibleSpaceBarSettings(BuildContext context) => context.dependOnInheritedWidgetOfExactType();

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
    MangaDetailScreenState state,
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
      body: NestedScrollView(
        headerSliverBuilder: (context, isInnerBoxScrolled) => [
          SliverAppBar(
            stretch: true,
            pinned: true,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height * 0.25,
            titleSpacing: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56),
              // TODO: @robzimpulse - overlapping title with actions button
              title: _title(),
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
                StretchMode.blurBackground,
              ],
              background: _appBarBackground(),
            ),
            actions: [
              _downloadButton(),
              _filterButton(),
              _shareButton(context: context),
            ],
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () => _cubit(context).init(),
          child: _content(),
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
          CachedNetworkImage(
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
          DecoratedBox(
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
        ],
      ),
    );
  }

  Widget _downloadButton() {
    return _builder(
      buildWhen: (prev, curr) => prev.chapters != curr.chapters,
      builder: (context, state) => state.chapters?.isNotEmpty == true
          ? PopupMenuButton<DownloadOption>(
              icon: const Icon(Icons.download),
              onSelected: (value) => _onTapDownload(
                context,
                value,
                state,
              ),
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
        icon: const Icon(Icons.filter_list),
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
      icon: const Icon(Icons.share),
      onPressed: () => _onTapShare(context),
    );
  }

  Widget _title() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoadingManga != curr.isLoadingManga,
        prev.manga?.title != curr.manga?.title,
      ].any((e) => e),
      builder: (context, state) => Builder(
        builder: (context) {
          final settings = _flexibleSpaceBarSettings(context);

          if (settings == null) return const SizedBox.shrink();

          final brightness = Theme.of(context).brightness;
          final style = Theme.of(context).textTheme.titleLarge;
          final double deltaExtent = settings.maxExtent - settings.minExtent;
          final double progress = clampDouble(
            1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent,
            0.0,
            1.0,
          );

          return ShimmerLoading.multiline(
            isLoading: state.isLoadingManga,
            width: 100,
            height: 20,
            lines: 1,
            child: Text(
              state.manga?.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: style?.copyWith(
                color: Color.lerp(
                  switch(brightness) {
                    Brightness.dark => Colors.white,
                    Brightness.light => Colors.black,
                  },
                  Colors.white,
                  progress,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chapters() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.errorChapters != curr.errorChapters,
        prev.isLoadingChapters != curr.isLoadingChapters,
        prev.chaptersKey != curr.chaptersKey,
      ].any((e) => e),
      builder: (context, state) {
        List<Widget> children;

        final error = state.errorChapters;
        final chapters = state.chaptersKey;
        if (error != null) {
          children = [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ];
        } else if (state.isLoadingChapters) {
          children = [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    ShimmerLoading.multiline(
                      isLoading: state.isLoadingChapters,
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
                          isLoading: state.isLoadingChapters,
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
          ];
        } else if (chapters.isEmpty == true) {
          children = [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No Chapter',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ];
        } else {
          children = [
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
          ];
        }

        return MultiSliver(
          children: children,
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

  Widget _content() {
    return CustomScrollView(
      slivers: [
        _builder(
          buildWhen: (prev, curr) => [
            prev.isLoadingManga != curr.isLoadingManga,
            prev.isOnLibrary != curr.isOnLibrary,
            prev.manga != curr.manga,
          ].any((e) => e),
          builder: (context, state) => MangaDetailWidget(
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
          ),
        ),
        _chapters(),
      ],
    );
  }

  Widget _separator() => const Divider(height: 1);
}
