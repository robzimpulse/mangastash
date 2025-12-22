import 'package:core_storage/core_storage.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'search_manga_screen_cubit.dart';
import 'search_manga_screen_state.dart';

class SearchMangaScreen extends StatefulWidget {
  const SearchMangaScreen({super.key, required this.imagesCacheManager});

  final ImagesCacheManager imagesCacheManager;

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) {
        return SearchMangaScreenCubit(listenSourceUseCase: locator());
      },
      child: SearchMangaScreen(imagesCacheManager: locator()),
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

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
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
                    hintStyle: DefaultTextStyle.of(context).style,
                  ),
                  cursorColor: DefaultTextStyle.of(context).style.color,
                  style: DefaultTextStyle.of(context).style,
                  onSubmitted: (value) {
                    _cubit(context).search(keyword: value);
                  },
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
                          Text(source.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // TODO: @robzimpulse - add manga grid widget with states
                Container(color: Colors.red),
                // TODO: @robzimpulse - add manga grid widget with states
                Container(color: Colors.green),
                // TODO: @robzimpulse - add manga grid widget with states
                Container(color: Colors.blue),
              ],
            ),
          ),
        );
      },
    );
  }
}
