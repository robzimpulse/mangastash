import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_manga_screen_cubit.dart';
import 'browse_source_manga_screen_cubit_state.dart';

class BrowseSourceMangaScreen extends StatefulWidget {
  const BrowseSourceMangaScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;

  final String url;

  static Widget create({
    required ServiceLocator locator,
    required String title,
    required String url,
  }) {
    return BlocProvider(
      create: (context) => BrowseSourceMangaScreenCubit(
        getCoverArtUseCase: locator(),
        searchMangaUseCase: locator(),
        listenListTagUseCase: locator(),
      )..init(),
      child: BrowseSourceMangaScreen(
        title: title,
        url: url,
      ),
    );
  }

  @override
  State<BrowseSourceMangaScreen> createState() =>
      _BrowseSourceMangaScreenState();
}

class _BrowseSourceMangaScreenState extends State<BrowseSourceMangaScreen> {
  final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) {
      context.read<BrowseSourceMangaScreenCubit>().next();
    },
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
        title: BlocBuilder<BrowseSourceMangaScreenCubit,
            BrowseSourceMangaScreenCubitState>(
          buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
          builder: (context, state) {
            if (!state.isSearchActive) {
              return Text(widget.title);
            }

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
              onSubmitted: (value) {
                final cubit = context.read<BrowseSourceMangaScreenCubit>();
                cubit.init(title: value);
              },
            );
          },
        ),
        actions: [
          BlocBuilder<BrowseSourceMangaScreenCubit,
              BrowseSourceMangaScreenCubitState>(
            buildWhen: (prev, curr) {
              return prev.isSearchActive != curr.isSearchActive;
            },
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
                onPressed: () {
                  final cubit = context.read<BrowseSourceMangaScreenCubit>();
                  cubit.searchMode(!state.isSearchActive);
                },
              );
            },
          ),
          PopupMenuButton<MangaShelfItemLayout>(
            icon: BlocBuilder<BrowseSourceMangaScreenCubit,
                BrowseSourceMangaScreenCubitState>(
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
            onSelected: (value) {
              final cubit = context.read<BrowseSourceMangaScreenCubit>();
              cubit.updateLayout(value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<BrowseSourceMangaScreenCubit,
          BrowseSourceMangaScreenCubitState>(
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

          if (state.errorMessage?.isNotEmpty == true) {
            return Center(
              child: Text(
                state.errorMessage ?? '',
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
                controller: _scrollController,
                isLoadingNextPage: state.isPagingNextPage,
                loadingIndicator: indicator,
                separator: const Divider(height: 1, thickness: 1),
                children: children.toList(),
              );
          }
        },
      ),
    );
  }
}
