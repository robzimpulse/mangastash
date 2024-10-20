import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
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
    required this.launchUrlUseCase,
  });

  final ValueSetter<String?>? onTapChapter;

  final Future<MangaChapterConfig?> Function(MangaChapterConfig?)? onTapSort;

  final LaunchUrlUseCase launchUrlUseCase;

  static Widget create({
    required ServiceLocator locator,
    required String? sourceId,
    required String? mangaId,
    ValueSetter<String?>? onTapChapter,
    Future<MangaChapterConfig?> Function(MangaChapterConfig?)? onTapSort,
  }) {
    return BlocProvider(
      create: (context) => MangaDetailScreenCubit(
        initialState: MangaDetailScreenState(
          mangaId: mangaId,
          sourceId: sourceId,
        ),
        getMangaUseCase: locator(),
        getListChapterUseCase: locator(),
        getMangaSourceUseCase: locator(),
        addToLibraryUseCase: locator(),
        listenAuth: locator(),
        removeFromLibraryUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
      )..init(),
      child: MangaDetailScreen(
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
  Widget _builder({
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

  void _onTapDownload(BuildContext context, DownloadOption option) {
    // TODO: implement this
    context.showSnackBar(message: '🚧🚧🚧 Under Construction $option 🚧🚧🚧');
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
      appBar: AppBar(
        title: _title(),
        elevation: 0,
        actions: [
          PopupMenuButton<DownloadOption>(
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
          ),
          _builder(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () async {
                final result = await widget.onTapSort?.call(state.config);
                if (!context.mounted || result == null) return;
                _cubit(context).updateMangaConfig(result);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _onTapShare(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _cubit(context).init(),
        child: _content(),
      ),
    );
  }

  Widget _title() {
    return _builder(
      builder: (context, state) => ShimmerLoading.multiline(
        isLoading: state.isLoading,
        width: 100,
        height: 20,
        lines: 1,
        child: Text(state.manga?.title ?? ''),
      ),
    );
  }

  List<Widget> _chapters(BuildContext context, MangaDetailScreenState state) {
    final error = state.error;
    if (error != null) {
      return [
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
    }

    if (state.isLoading) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                ShimmerLoading.multiline(
                  isLoading: state.isLoading,
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
              (context, index) => ShimmerLoading.multiline(
                isLoading: state.isLoading,
                width: double.infinity,
                height: 15,
                lines: 3,
              ),
              childCount: 50,
            ),
          ),
        ),
      ];
    }

    final chapters = state.processedChapters;
    if (chapters == null || chapters.isEmpty == true) {
      return [
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
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
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
      ..._group(context: context, volumes: chapters, config: state.config)
    ];
  }

  List<Widget> _group({
    required BuildContext context,
    required Map<num?, Map<num?, List<MangaChapter>>> volumes,
    required MangaChapterConfig? config,
  }) {
    List<Widget> view = [];
    for (final volume in volumes.entries) {
      List<Widget> children = [];
      for (final chapter in volume.value.entries) {
        children.add(
          SliverPadding(
            padding: const EdgeInsets.only(left: 12),
            sliver: MultiSliver(
              pushPinnedChildren: true,
              children: [
                SliverPinnedHeader(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Chapter ${chapter.key}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: (chapter.value.length * 2) - 1,
                    semanticIndexCallback: (Widget _, int index) {
                      return index.isEven ? index ~/ 2 : null;
                    },
                    (context, index) {
                      final int itemIndex = index ~/ 2;
                      return index.isOdd
                          ? _separator()
                          : _chapter(
                              context: context,
                              chapter: chapter.value[itemIndex],
                              config: config,
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final key = volume.key;

      if (key == null) {
        view.addAll(children);
      } else {
        view.add(
          SliverPadding(
            padding: const EdgeInsets.only(left: 12),
            sliver: MultiSliver(
              pushPinnedChildren: true,
              children: [
                SliverPinnedHeader(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Volume $key',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                ...children,
              ],
            ),
          ),
        );
      }
    }

    return view;
  }

  Widget _content() {
    return _builder(
      builder: (context, state) => MangaDetailWidget(
        coverUrl: state.manga?.coverUrl,
        title: state.manga?.title,
        author: state.manga?.author,
        status: state.manga?.status,
        description: state.manga?.description,
        tags: state.manga?.tags?.map((e) => e.name).whereNotNull().toList(),
        horizontalPadding: 12,
        isOnLibrary: state.isOnLibrary == true,
        onTapAddToLibrary: () => _onTapAddToLibrary(context, state),
        onTapWebsite: () => _onTapWebsite(context, state),
        onTapTag: (name) => _onTapTag(
          context,
          tag: state.manga?.tags?.firstWhere((e) => e.name == name),
        ),
        isLoading: state.isLoading,
        child: _chapters(context, state),
      ),
    );
  }

  Widget _separator() => const Divider(height: 1);

  Widget _chapter({
    required BuildContext context,
    required MangaChapter? chapter,
    required MangaChapterConfig? config,
  }) {
    if (chapter == null) return const SizedBox.shrink();

    final display = config?.display;

    String? title = chapter.title;
    String? chapterName = chapter.chapter;

    if (display != null) {
      switch (display) {
        case MangaChapterDisplayEnum.title:
          chapterName = null;
          break;
        case MangaChapterDisplayEnum.chapter:
          title = null;
          break;
      }
    }

    return InkWell(
      onTap: () => widget.onTapChapter?.call(chapter.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  [
                    if (chapter.volume != null) 'Vol ${chapter.volume}',
                    if (chapterName != null) 'Ch $chapterName',
                  ].join(' '),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      if (chapter.publishAt != null)
                        '${chapter.publishAt?.asDateTime?.readableFormat}',
                      if (title != null) title,
                    ].join(' - '),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
