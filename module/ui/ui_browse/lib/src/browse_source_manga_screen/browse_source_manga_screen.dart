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
          PopupMenuButton<int>(
            icon: const Icon(Icons.grid_view_sharp),
            itemBuilder: (context) {
              // TODO: set menu for layout here
              return const [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("My Account"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("Settings"),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text("Logout"),
                ),
              ];
            },
            onSelected: (value) {},
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
              prev.hasNextPage != curr.hasNextPage;
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
            (e) => MangaGridItemWidget(
              title: e.title,
              coverUrl: e.coverUrl,
            ),
          );

          return MangaGridWidget(
            controller: _scrollController,
            crossAxisCount: _crossAxisCount(context),
            childAspectRatio: (100 / 140),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            isLoadingNextPage: state.isPagingNextPage,
            loadingIndicator: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            children: children.toList(),
          );
        },
      ),
    );
  }
}
