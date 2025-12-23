import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/manga_grid_widget/manga_grid_widget.dart';
import 'search_manga_screen_cubit.dart';
import 'search_manga_screen_state.dart';

class SearchMangaScreen extends StatefulWidget {
  const SearchMangaScreen({
    super.key,
    required this.imagesCacheManager,
    required this.widgetBuilder,
  });

  final ImagesCacheManager imagesCacheManager;

  final Widget Function(SourceEnum, SearchMangaScreenCubit) widgetBuilder;

  static Widget create({
    required ServiceLocator locator,
    void Function(Manga, SearchMangaParameter)? onTapManga,
  }) {
    return BlocProvider(
      create: (context) {
        return SearchMangaScreenCubit(listenSourceUseCase: locator());
      },
      child: SearchMangaScreen(
        imagesCacheManager: locator(),
        widgetBuilder: (source, cubit) {
          return MangaGridWidget.create(
            locator: locator,
            source: source,
            parent: cubit,
            onTapManga: onTapManga,
          );
        },
      ),
    );
  }

  @override
  State<SearchMangaScreen> createState() => _SearchMangaScreenState();
}

class _SearchMangaScreenState extends State<SearchMangaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  SearchMangaScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<SearchMangaScreenState> builder,
    BlocBuilderCondition<SearchMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<SearchMangaScreenCubit, SearchMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.sources != curr.sources,
      builder: (context, state) {
        final theme = Theme.of(context);

        return DefaultTabController(
          length: state.sources.length,
          child: ScaffoldScreen(
            appBar: AppBar(
              centerTitle: false,
              title: Container(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: false,
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  cursorColor: Colors.white,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                  onSubmitted: (value) => _cubit(context).set(keyword: value),
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  ...state.sources.map(
                    (source) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CachedNetworkImage(
                            imageUrl: source.icon,
                            cacheManager: widget.imagesCacheManager,
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            source.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ...state.sources.map(
                  (source) => widget.widgetBuilder(source, _cubit(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
