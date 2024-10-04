import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_detail_cubit.dart';
import 'manga_detail_state.dart';

class MangaDetailScreen extends StatefulWidget {
  const MangaDetailScreen({
    super.key,
    required this.onTapChapter,
    required this.onTapSort,
    required this.launchUrlUseCase,
  });

  final Function(BuildContext, String?) onTapChapter;

  final Function(BuildContext) onTapSort;

  final LaunchUrlUseCase launchUrlUseCase;

  static Widget create({
    required ServiceLocator locator,
    required String? sourceId,
    required String? mangaId,
    required Function(BuildContext, String?) onTapChapter,
    required Function(BuildContext) onTapSort,
  }) {
    return BlocProvider(
      create: (context) => MangaDetailCubit(
        initialState: MangaDetailState(
          mangaId: mangaId,
          sourceId: sourceId,
        ),
        getMangaUseCase: locator(),
        getListChapterUseCase: locator(),
        getMangaSourceUseCase: locator(),
        listenMangaChapterConfig: locator(),
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
    required BlocWidgetBuilder<MangaDetailState> builder,
    BlocBuilderCondition<MangaDetailState>? buildWhen,
  }) {
    return BlocBuilder<MangaDetailCubit, MangaDetailState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  MangaDetailCubit _cubit(BuildContext context) => context.read();

  void _onTapFavorite(BuildContext context) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapWebsite(BuildContext context, MangaDetailState state) async {
    final url = state.manga?.webUrl;

    if (url == null || url.isEmpty) {
      context.showSnackBar(message: 'Could not launch source url');
      return;
    }

    final result = await widget.launchUrlUseCase.launch(
      url: url,
      mode: LaunchMode.externalApplication,
    );

    if (result || !mounted) return;
    context.showSnackBar(message: 'Could not launch $url');
  }

  void _onTapTag(BuildContext context, {MangaTag? tag}) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapDownload(BuildContext context, DownloadOption option) {
    // TODO: implement this
    context.showSnackBar(
      message: '🚧🚧🚧 Under Construction $option 🚧🚧🚧',
    );
  }

  void _onTapShare(BuildContext context) {
    // TODO: implement this
    context.showSnackBar(
      message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
    );
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
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => widget.onTapSort(context),
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

  List<Widget> _chapters(BuildContext context, MangaDetailState state) {
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

    final chapters = state.chapters;
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

    final sortOrder = state.config?.sortOrder;
    final sortOption = state.config?.sortOption;
    List<MangaChapter> sortedChapter = chapters;

    if (sortOrder != null && sortOption != null) {
      switch (sortOption) {
        case MangaChapterSortOptionEnum.chapterNumber:
          switch (sortOrder) {
            case MangaChapterSortOrderEnum.asc:
              sortedChapter = chapters.sorted(
                (a, b) {
                  final aChapter = int.tryParse(a.chapter ?? '');
                  final bChapter = int.tryParse(b.chapter ?? '');
                  if (aChapter == null || bChapter == null) return 0;
                  return -aChapter.compareTo(bChapter);
                },
              );
              break;
            case MangaChapterSortOrderEnum.desc:
              sortedChapter = chapters.sorted(
                (a, b) {
                  final aChapter = int.tryParse(a.chapter ?? '');
                  final bChapter = int.tryParse(b.chapter ?? '');
                  if (aChapter == null || bChapter == null) return 0;
                  return aChapter.compareTo(bChapter);
                },
              );
              break;
          }

          break;
        case MangaChapterSortOptionEnum.uploadDate:
          switch (sortOrder) {
            case MangaChapterSortOrderEnum.asc:
              sortedChapter = chapters.sorted(
                (a, b) {
                  final aDate = a.readableAt?.asDateTime;
                  final bDate = b.readableAt?.asDateTime;
                  if (aDate == null || bDate == null) return 0;
                  return aDate.compareTo(bDate);
                },
              );
              break;
            case MangaChapterSortOrderEnum.desc:
              sortedChapter = chapters.sorted(
                (a, b) {
                  final aDate = a.readableAt?.asDateTime;
                  final bDate = b.readableAt?.asDateTime;
                  if (aDate == null || bDate == null) return 0;
                  return -aDate.compareTo(bDate);
                },
              );
              break;
          }
          break;
      }
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text(
                '${sortedChapter.length} Chapters',
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
            childCount: (sortedChapter.length * 2) - 1,
            semanticIndexCallback: (Widget _, int index) {
              return index.isEven ? index ~/ 2 : null;
            },
            (context, index) {
              final int itemIndex = index ~/ 2;
              return index.isOdd
                  ? _separator()
                  : _chapter(
                      context: context,
                      chapter: sortedChapter[itemIndex],
                      config: state.config,
                    );
            },
          ),
        ),
      ),
    ];
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
        onTapFavorite: () => _onTapFavorite(context),
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
      onTap: () => widget.onTapChapter.call(context, chapter.id),
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
                      if (chapter.readableAt != null)
                        '${chapter.readableAt?.asDateTime?.ddLLLLyy}',
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
