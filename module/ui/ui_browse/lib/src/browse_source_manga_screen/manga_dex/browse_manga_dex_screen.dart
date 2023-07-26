import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_dex_cubit.dart';
import 'browse_manga_dex_state.dart';
import 'sheet/manga_dex_filter_bottom_sheet.dart';

class BrowseMangaDexScreen extends StatefulWidget {
  const BrowseMangaDexScreen({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  State<BrowseMangaDexScreen> createState() => _BrowseMangaDexScreenState();

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaDexCubit(
        searchMangaUseCase: locator(),
        getCoverArtUseCase: locator(),
      )..init(),
      child: BrowseMangaDexScreen(locator: locator),
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
    final responsive = ResponsiveBreakpoints.of(context);
    if (responsive.isMobile) return 3;
    if (responsive.isTablet) return 5;
    if (responsive.isDesktop) return 8;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: _title(),
        elevation: 0,
        actions: [
          _searchIcon(),
          _layoutIcon(),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _sortAndFilter(size: const Size.fromHeight(52)),
        ),
      ),
      body: _content(),
    );
  }

  Widget _sortAndFilter({Size? size}) {
    return _bloc(
      buildWhen: (prev, curr) => prev.parameter != curr.parameter,
      builder: (context, state) {
        return GappedToggleButton(
          size: size,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          selectedColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedColor: Theme.of(context).appBarTheme.backgroundColor,
          icons: const [
            Icon(Icons.favorite),
            Icon(Icons.update),
            Icon(Icons.filter_list)
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

            if (index == 2) {
              final result = await context.showBottomSheet<List<MangaTag>>(
                builder: (context) => MangaDexFilterBottomSheet.create(
                  locator: widget.locator,
                  includedTags: state.parameter.includedTags,
                  excludedTags: state.parameter.excludedTags,
                ),
              );

              if (!mounted || result == null) return;
              _cubit(context).setFilter(result);
            }
          },
        );
      },
    );
  }

  Widget _title() {
    return _bloc(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) {
        if (!state.isSearchActive) return const Text('MangaDex');
        return TextField(
          controller: _searchController..clear(),
          focusNode: _searchFocusNode..requestFocus(),
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
    );
  }

  Widget _searchIcon() {
    return _bloc(
      buildWhen: (prev, curr) {
        return prev.isSearchActive != curr.isSearchActive;
      },
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
      icon: _bloc(
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
    return _bloc(
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
              isLoadingNextPage: state.isPagingNextPage,
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
              isLoadingNextPage: state.isPagingNextPage,
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
              isLoadingNextPage: state.isPagingNextPage,
              loadingIndicator: indicator,
              separator: const Divider(height: 1, thickness: 1),
              children: children.toList(),
            );
        }
      },
    );
  }

  Widget _bloc({
    required BlocWidgetBuilder<BrowseMangaDexState> builder,
    BlocBuilderCondition<BrowseMangaDexState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaDexCubit, BrowseMangaDexState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  BrowseMangaDexCubit _cubit(BuildContext context) {
    return context.read<BrowseMangaDexCubit>();
  }
}
