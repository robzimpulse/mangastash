import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_manga_screen_cubit.dart';
import 'browse_source_manga_screen_cubit_state.dart';

class BrowseSourceMangaScreen extends StatelessWidget {

  BrowseSourceMangaScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) => context.read<BrowseSourceMangaScreenCubit>().next(),
  );

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

  Widget _bloc({
    BlocBuilderCondition<BrowseSourceMangaScreenCubitState>? buildWhen,
    required BlocWidgetBuilder<BrowseSourceMangaScreenCubitState> builder,
  }) {
    return BlocBuilder<BrowseSourceMangaScreenCubit, BrowseSourceMangaScreenCubitState>(
      buildWhen: buildWhen,
      builder: builder,
    );
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
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_sharp),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {},
          ),
        ],
      ),
      body: _bloc(
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
