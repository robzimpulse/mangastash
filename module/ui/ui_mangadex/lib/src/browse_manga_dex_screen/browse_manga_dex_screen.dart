import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import '../filter_bottom_sheet/filter_bottom_sheet.dart';
import 'browse_manga_dex_cubit.dart';
import 'browse_manga_dex_state.dart';

class BrowseMangaDexScreen extends StatefulWidget {
  const BrowseMangaDexScreen({
    super.key,
    required this.launchUrlUseCase,
    required this.listenListTagUseCase,
    required this.onTapManga,
  });

  final LaunchUrlUseCase launchUrlUseCase;

  final ListenListTagUseCaseDeprecated listenListTagUseCase;

  final Function(BuildContext, MangaDeprecated) onTapManga;

  @override
  State<BrowseMangaDexScreen> createState() => _BrowseMangaDexScreenState();

  static Widget create({
    required ServiceLocator locator,
    required Function(BuildContext, MangaDeprecated) onTapManga,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaDexCubit(
        searchMangaUseCase: locator(),
        getCoverArtUseCase: locator(),
        getAuthorUseCase: locator(),
        initialState: const BrowseMangaDexState(
          parameter: SearchMangaParameterDeprecated(
            orders: {SearchOrders.rating: OrderDirections.descending},
          ),
        ),
      )..init(),
      child: BrowseMangaDexScreen(
        launchUrlUseCase: locator(),
        listenListTagUseCase: locator(),
        onTapManga: onTapManga,
      ),
    );
  }
}

class _BrowseMangaDexScreenState extends State<BrowseMangaDexScreen> {
  final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) => context.read<BrowseMangaDexCubit>().next(),
  );

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  int _crossAxisCount(BuildContext context) {
    if (_breakpoints(context).isMobile) return 3;
    if (_breakpoints(context).isTablet) return 5;
    if (_breakpoints(context).isDesktop) return 8;
    return 12;
  }

  void _onTapOpenInBrowser(BuildContext context) async {
    final result = await widget.launchUrlUseCase.launch(
      url: source.url ?? '',
      mode: LaunchMode.externalApplication,
    );

    if (result || !mounted) return;
    context.showSnackBar(message: 'Could not launch ${source.url}');
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(),
        elevation: 0,
        actions: [
          _searchIcon(),
          _layoutIcon(),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _onTapOpenInBrowser(context),
          ),
        ],
        bottom: _sortAndFilter().preferredSize(
          context: context,
          size: const Size.fromHeight(52),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _cubit(context).init(),
        child: _content(),
      ),
    );
  }

  Widget _sortAndFilter() {
    return _builder(
      buildWhen: (prev, curr) => prev.parameter != curr.parameter,
      builder: (context, state) {
        return GappedToggleButtonWidget(
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          selectedColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedColor: Theme.of(context).appBarTheme.backgroundColor,
          icons: const [
            Icon(Icons.favorite),
            Icon(Icons.update),
            Icon(Icons.filter_list),
          ],
          labels: const ['Favorite', 'Latest', 'Filter'],
          isSelected: [
            state.parameter.orders?[SearchOrders.rating] ==
                OrderDirections.descending,
            state.parameter.orders?[SearchOrders.latestUploadedChapter] ==
                OrderDirections.descending,
            state.parameter.includedTags.isNotEmpty ||
                state.parameter.excludedTags.isNotEmpty,
          ],
          onPressed: (index) async {
            if (index == 0) _cubit(context).onTapFavorite();
            if (index == 1) _cubit(context).onTapLatest();
            if (index == 2) _showFilterBottomSheet();
          },
        );
      },
    );
  }

  void _showFilterBottomSheet() async {
    final state = _cubit(context).state;
    final result = await context.showBottomSheet<List<MangaTagDeprecated>>(
      builder: (context) => FilterBottomSheet.create(
        listenListTagUseCase: widget.listenListTagUseCase,
        includedTags: state.parameter.includedTags,
        excludedTags: state.parameter.excludedTags,
      ),
    );

    if (!mounted || result == null) return;
    _cubit(context).setFilter(result);
  }

  Widget _title() {
    return _consumer(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) {
        if (!state.isSearchActive) return const Text('MangaDex');
        return TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _cubit(context).init(title: value),
        );
      },
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) {
        _searchController.clear();
        _searchFocusNode.requestFocus();
      },
    );
  }

  Widget _searchIcon() {
    return _builder(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
          onPressed: () => _cubit(context).searchMode(!state.isSearchActive),
        );
      },
    );
  }

  Widget _layoutIcon() {
    return PopupMenuButton<MangaShelfItemLayout>(
      icon: _builder(
        buildWhen: (prev, curr) => prev.layout != curr.layout,
        builder: (context, state) {
          switch (state.layout) {
            case MangaShelfItemLayout.comfortableGrid:
              return const Icon(Icons.grid_on);
            case MangaShelfItemLayout.compactGrid:
              return const Icon(Icons.grid_view_sharp);
            case MangaShelfItemLayout.list:
              return const Icon(Icons.list);
          }
        },
      ),
      itemBuilder: (context) {
        final options = MangaShelfItemLayout.values.map(
          (e) => PopupMenuItem<MangaShelfItemLayout>(
            value: e,
            child: Text(e.rawValue),
          ),
        );

        return options.toList();
      },
      onSelected: (value) => _cubit(context).updateLayout(value),
    );
  }

  Widget _content() {
    return _builder(
      buildWhen: (prev, curr) {
        return prev.mangas != curr.mangas ||
            prev.isLoading != curr.isLoading ||
            prev.errorMessage != curr.errorMessage ||
            prev.isPagingNextPage != curr.isPagingNextPage ||
            prev.hasNextPage != curr.hasNextPage ||
            prev.layout != curr.layout;
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.mangas.isEmpty) {
          if (state.errorMessage?.isNotEmpty == true) {
            return Center(
              child: Text(
                state.errorMessage ?? '',
                textAlign: TextAlign.center,
              ),
            );
          }

          return const Center(
            child: Text('Manga Empty'),
          );
        }

        final children = state.mangas.map(
          (e) => MangaShelfItem(
            title: e.title ?? '',
            coverUrl: e.coverUrl ?? '',
            layout: state.layout,
            onTap: () => widget.onTapManga.call(context, e),
          ),
        );

        const indicator = Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );

        switch (state.layout) {
          case MangaShelfItemLayout.comfortableGrid:
            return MangaShelfWidget.comfortableGrid(
              controller: _scrollController,
              hasNextPage: state.hasNextPage,
              loadingIndicator: indicator,
              crossAxisCount: _crossAxisCount(context),
              childAspectRatio: (100 / 140),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: children.toList(),
            );
          case MangaShelfItemLayout.compactGrid:
            return MangaShelfWidget.compactGrid(
              controller: _scrollController,
              hasNextPage: state.hasNextPage,
              loadingIndicator: indicator,
              crossAxisCount: _crossAxisCount(context),
              childAspectRatio: (100 / 140),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: children.toList(),
            );
          case MangaShelfItemLayout.list:
            return MangaShelfWidget.list(
              padding: const EdgeInsets.symmetric(vertical: 8),
              controller: _scrollController,
              hasNextPage: state.hasNextPage,
              loadingIndicator: indicator,
              separator: const Divider(height: 1, thickness: 1),
              children: children.toList(),
            );
        }
      },
    );
  }

  Widget _builder({
    required BlocWidgetBuilder<BrowseMangaDexState> builder,
    BlocBuilderCondition<BrowseMangaDexState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaDexCubit, BrowseMangaDexState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _consumer({
    required BlocWidgetBuilder<BrowseMangaDexState> builder,
    BlocBuilderCondition<BrowseMangaDexState>? buildWhen,
    required BlocWidgetListener<BrowseMangaDexState> listener,
    BlocListenerCondition<BrowseMangaDexState>? listenWhen,
  }) {
    return BlocConsumer<BrowseMangaDexCubit, BrowseMangaDexState>(
      builder: builder,
      listener: listener,
      buildWhen: buildWhen,
      listenWhen: listenWhen,
    );
  }

  BrowseMangaDexCubit _cubit(BuildContext context) {
    return context.read<BrowseMangaDexCubit>();
  }

  ResponsiveBreakpointsData _breakpoints(BuildContext context) {
    return ResponsiveBreakpoints.of(context);
  }

  MangaSource get source => const MangaSource(
        iconUrl: 'https://www.mangadex.org/favicon.ico',
        name: 'Manga Dex',
        url: 'https://www.mangadex.org',
        id: 'manga_dex',
      );
}
