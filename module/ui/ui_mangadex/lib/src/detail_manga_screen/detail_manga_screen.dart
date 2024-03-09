import 'package:collection/collection.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'detail_manga_cubit.dart';
import 'detail_manga_state.dart';

class DetailMangaScreen extends StatefulWidget {
  const DetailMangaScreen({super.key, required this.onTapChapter});

  final Function(BuildContext, String?) onTapChapter;

  static Widget create({
    required ServiceLocator locator,
    required String mangaId,
    required Function(BuildContext, String?) onTapChapter,
  }) {
    return BlocProvider(
      create: (context) => DetailMangaCubit(
        getAllChapterUseCase: locator(),
        initialState: DetailMangaState(
          parameter: SearchChapterParameterDeprecated(
            mangaId: mangaId,
            includes: const [Include.coverArt, Include.author],
            translatedLanguage: const [LanguageCodes.english],
            orders: const {ChapterOrders.chapter: OrderDirections.descending},
          ),
        ),
        getMangaUseCase: locator(),
      )..init(),
      child: DetailMangaScreen(
        onTapChapter: onTapChapter,
      ),
    );
  }

  @override
  State<DetailMangaScreen> createState() => _DetailMangaScreenState();
}

class _DetailMangaScreenState extends State<DetailMangaScreen> {
  Widget _builder({
    required BlocWidgetBuilder<DetailMangaState> builder,
    BlocBuilderCondition<DetailMangaState>? buildWhen,
  }) {
    return BlocBuilder<DetailMangaCubit, DetailMangaState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  DetailMangaCubit _cubit(BuildContext context) {
    return context.read<DetailMangaCubit>();
  }

  void _onTapFavorite(BuildContext context) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapWebsite(BuildContext context) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _onTapTag(BuildContext context, {MangaTagDeprecated? tag}) {
    // TODO: implement this
    return context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: _title(),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            // TODO: implement this
            onPressed: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            // TODO: implement this
            onPressed: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            // TODO: implement this
            onPressed: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
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

  List<Widget> _chapters(BuildContext context, DetailMangaState state) {
    if (state.errorMessage?.isNotEmpty == true) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                state.errorMessage ?? '',
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

    final chapters = state.manga?.chapters;
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
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text('${chapters.length} Chapters'),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: chapters.length,
            semanticIndexCallback: (Widget _, int index) {
              return index.isEven ? index ~/ 2 : null;
            },
            (context, index) {
              final int itemIndex = index ~/ 2;
              return index.isOdd
                  ? _separator()
                  : InkWell(
                      onTap: () => widget.onTapChapter.call(
                        context,
                        chapters[itemIndex].id,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(chapters[itemIndex].top),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(chapters[itemIndex].bottom),
                              ),
                            ],
                          ),
                        ],
                      ),
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
        onTapWebsite: () => _onTapWebsite(context),
        onTapTag: (name) => _onTapTag(
          context,
          tag: state.manga?.tags?.firstWhere((e) => e.name == name),
        ),
        isLoading: state.isLoading,
        child: _chapters(context, state),
      ),
    );
  }

  Widget _separator() => const SizedBox(height: 8);
}
