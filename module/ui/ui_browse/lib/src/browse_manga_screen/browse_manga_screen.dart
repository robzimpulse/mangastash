import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'browse_manga_screen_cubit.dart';
import 'browse_manga_screen_state.dart';

class BrowseMangaScreen extends StatefulWidget {
  const BrowseMangaScreen({
    super.key,
    required this.cacheManager,
    this.onTapManga,
    this.onTapFilter,
  });

  final Function(Manga, SearchMangaParameter)? onTapManga;

  final Future<SearchMangaParameter?>? Function(
    SearchMangaParameter? value,
    List<Tag> availableTags,
  )? onTapFilter;

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
    Function(Manga, SearchMangaParameter)? onTapManga,
    Future<SearchMangaParameter?>? Function(
      SearchMangaParameter? value,
      List<Tag> availableTags,
    )? onTapFilter,
    String? source,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaScreenCubit(
        initialState: BrowseMangaScreenState(
          source: source?.let((e) => SourceEnum.fromValue(name: source)),
        ),
        searchMangaUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
        addToLibraryUseCase: locator(),
        removeFromLibraryUseCase: locator(),
        prefetchMangaUseCase: locator(),
        listenPrefetchMangaUseCase: locator(),
        prefetchChapterUseCase: locator(),
        listenSearchParameterUseCase: locator(),
        getTagsUseCase: locator(),
        crawlUrlUseCase: locator(),
      )..init(),
      child: BrowseMangaScreen(
        cacheManager: locator(),
        onTapManga: onTapManga,
        onTapFilter: onTapFilter,
      ),
    );
  }

  @override
  State<BrowseMangaScreen> createState() => _BrowseMangaScreenState();
}

class _BrowseMangaScreenState extends State<BrowseMangaScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  BrowseMangaScreenCubit _cubit(BuildContext context) => context.read();

  int _crossAxisCount(BuildContext context) {
    if (_breakpoints(context).isMobile) return 3;
    if (_breakpoints(context).isTablet) return 5;
    if (_breakpoints(context).isDesktop) return 8;
    return 12;
  }

  ResponsiveBreakpointsData _breakpoints(BuildContext context) {
    return ResponsiveBreakpoints.of(context);
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<BrowseMangaScreenState> builder,
    BlocBuilderCondition<BrowseMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaScreenCubit, BrowseMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  BlocConsumer _consumer({
    required BlocWidgetBuilder<BrowseMangaScreenState> builder,
    BlocBuilderCondition<BrowseMangaScreenState>? buildWhen,
    required BlocWidgetListener<BrowseMangaScreenState> listener,
    BlocListenerCondition<BrowseMangaScreenState>? listenWhen,
  }) {
    return BlocConsumer<BrowseMangaScreenCubit, BrowseMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  void _onTapMenu({
    required BuildContext context,
    required Manga manga,
    required bool isOnLibrary,
  }) async {
    final result = await context.pushNamed<MangaMenu>(
      CommonRoutePath.menu,
      queryParameters: {
        CommonRoutePath.menuIsOnLibrary: isOnLibrary ? 'true' : 'false',
      },
    );

    if (result == null || !context.mounted) return;

    switch (result) {
      case MangaMenu.download:
        _cubit(context).download(manga: manga);
      case MangaMenu.library:
        _cubit(context).addToLibrary(manga: manga);
      case MangaMenu.prefetch:
        _cubit(context).prefetch(manga: manga);
    }
  }

  Widget _menuLayout({required BuildContext context}) {
    return PopupMenuButton<MangaShelfItemLayout>(
      icon: _builder(
        buildWhen: (prev, curr) => prev.layout != curr.layout,
        builder: (context, state) {
          switch (state.layout) {
            case MangaShelfItemLayout.comfortableGrid:
              return const Icon(Icons.grid_view_sharp);
            case MangaShelfItemLayout.compactGrid:
              return const Icon(Icons.grid_on);
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
      onSelected: (value) => _cubit(context).update(layout: value),
    );
  }

  Widget _menuSource({required BuildContext context}) {
    return IconButton(
      icon: const Icon(Icons.open_in_browser),
      onPressed: () => _cubit(context).recrawl(),
    );
  }

  Widget _menuSearch({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) => IconButton(
        icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
        onPressed: () => _cubit(context).update(
          isSearchActive: !state.isSearchActive,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(context),
        actions: [
          _menuSearch(context: context),
          _menuLayout(context: context),
          _menuSource(context: context),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 44),
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: _menus(context),
            ),
          ),
        ),
      ),
      body: NextPageNotificationWidget(
        onLoadNextPage: () => _cubit(context).next(),
        child: RefreshIndicator(
          onRefresh: () => _cubit(context).init(useCache: false),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _menus(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.appBarTheme.iconTheme?.color;
    final labelStyle = theme.textTheme.labelSmall;
    final buttonStyle = theme.outlinedButtonTheme.style?.copyWith(
      visualDensity: VisualDensity.compact,
      side: WidgetStatePropertyAll(
        const BorderSide(width: 1).copyWith(color: color),
      ),
    );

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _builder(
            buildWhen: (prev, curr) => [
              prev.isFavoriteActive != curr.isFavoriteActive,
              prev.parameter != curr.parameter,
            ].contains(true),
            builder: (context, state) => IconButton.outlined(
              style: buttonStyle?.copyWith(
                backgroundColor: state.isFavoriteActive
                    ? const WidgetStatePropertyAll(Colors.grey)
                    : null,
              ),
              icon: Icon(Icons.favorite, color: color),
              onPressed: () => _cubit(context).init(
                parameter: state.parameter.copyWith(
                  orders: Map.fromEntries(
                    [
                      MapEntry(
                        state.isFavoriteActive
                            ? SearchOrders.relevance
                            : SearchOrders.rating,
                        OrderDirections.descending,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _builder(
            buildWhen: (prev, curr) => [
              prev.isUpdatedActive != curr.isUpdatedActive,
              prev.parameter != curr.parameter,
            ].contains(true),
            builder: (context, state) => IconButton.outlined(
              style: buttonStyle?.copyWith(
                backgroundColor: state.isUpdatedActive
                    ? const WidgetStatePropertyAll(Colors.grey)
                    : null,
              ),
              icon: Icon(Icons.update, color: color),
              onPressed: () => _cubit(context).init(
                parameter: state.parameter.copyWith(
                  orders: Map.fromEntries(
                    [
                      MapEntry(
                        state.isUpdatedActive
                            ? SearchOrders.relevance
                            : SearchOrders.updatedAt,
                        OrderDirections.descending,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _builder(
            buildWhen: (prev, curr) => [
              prev.parameter != curr.parameter,
              prev.isFilterActive != curr.isFilterActive,
              prev.tags != curr.tags,
            ].contains(true),
            builder: (context, state) => OutlinedButton.icon(
              style: buttonStyle?.copyWith(
                backgroundColor: state.isFilterActive
                    ? const WidgetStatePropertyAll(Colors.grey)
                    : null,
              ),
              icon: Icon(Icons.filter_list, color: color),
              label: Text('Filter', style: labelStyle?.copyWith(color: color)),
              onPressed: () async {
                final result = await widget.onTapFilter?.call(
                  state.parameter,
                  state.tags,
                );
                if (context.mounted && result != null) {
                  _cubit(context).init(parameter: result);
                }
              },
            ),
          ),
        ].intersperse(const SizedBox(width: 4)).toList(),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return _consumer(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) {
        state.isSearchActive
            ? _searchFocusNode.requestFocus()
            : _searchFocusNode.unfocus();
        _cubit(context).init(
          parameter: state.parameter.copyWith(
            title: state.isSearchActive ? _searchController.text : '',
          ),
        );
      },
      buildWhen: (prev, curr) => [
        prev.source != curr.source,
        prev.isSearchActive != curr.isSearchActive,
        prev.parameter != curr.parameter,
      ].contains(true),
      builder: (context, state) => !state.isSearchActive
          ? Text(state.source?.name ?? '')
          : Container(
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
                onSubmitted: (value) => _cubit(context).init(
                  parameter: state.parameter.copyWith(title: value),
                ),
              ),
            ),
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.isLoading != curr.isLoading,
        prev.error != curr.error,
        prev.mangas != curr.mangas,
        prev.libraryMangaIds != curr.libraryMangaIds,
        prev.layout != curr.layout,
        prev.parameter != curr.parameter,
        prev.prefetchedMangaIds != curr.prefetchedMangaIds,
        prev.hasNextPage != curr.hasNextPage,
      ].contains(true),
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.error != null) {
          return Center(
            child: Text(
              state.error.toString(),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state.mangas.isEmpty) {
          return const Center(
            child: Text('Manga Empty'),
          );
        }

        final children = state.mangas.map(
          (e) => MangaShelfItem(
            cacheManager: widget.cacheManager,
            title: e.title ?? '',
            coverUrl: e.coverUrl ?? '',
            layout: state.layout,
            onTap: () => widget.onTapManga?.call(e, state.parameter),
            onLongPress: () => _onTapMenu(
              context: context,
              manga: e,
              isOnLibrary: state.libraryMangaIds.contains(e.id),
            ),
            isOnLibrary: state.libraryMangaIds.contains(e.id),
            isPrefetching: state.prefetchedMangaIds.contains(e.id),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}
