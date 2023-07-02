import 'package:data_manga/data_manga.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:core_route/core_route.dart';

import '../../widget/advanced_search_bottom_sheet/advanced_search_bottom_sheet.dart';
import 'search_screen_cubit.dart';
import 'search_screen_cubit_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.locator});

  final ServiceLocator locator;

  @override
  State<SearchScreen> createState() => _SearchScreenState();

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) => SearchScreenCubit(
        searchMangaUseCase: locator(),
        listenListTagUseCase: locator(),
        getCoverArtUseCase: locator(),
      ),
      child: SearchScreen(locator: locator),
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) => context.read<SearchScreenCubit>().next(),
  );

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _crossAxisCount(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    if (responsive.isMobile) return 3;
    if (responsive.isTablet) return 5;
    if (responsive.isDesktop) return 8;
    return 12;
  }

  void onChangeTitle(String value) {
    final cubit = context.read<SearchScreenCubit>();
    final state = cubit.state;
    cubit.update(
      parameter: state.parameter.copyWith(title: value, offset: 0),
      mangaSectionState: cubit.state.mangaSectionState.copyWith(mangas: []),
    );
  }

  void _onTapFilter({required List<Tag> tags}) async {
    // TODO: Replace with commented code after screen done
    // context.pushForResult<SearchMangaParameter>(
    //   '/search/setting',
    //   callback: (value) {
    //     if (value == null || !mounted) return;
    //     final cubit = context.read<SearchScreenCubit>();
    //     cubit.update(
    //       parameter: value.copyWith(offset: 0),
    //       mangaSectionState: cubit.state.mangaSectionState.copyWith(mangas: []),
    //     );
    //     if (value.title?.isNotEmpty == true) cubit.search();
    //   },
    // );

    final cubit = context.read<SearchScreenCubit>();
    final data = await context.showBottomSheet<SearchMangaParameter>(
      builder: (context) => AdvancedSearchBottomSheet.create(
        locator: widget.locator,
        tags: tags,
        parameter: cubit.state.parameter,
      ),
    );
    if (!mounted || data == null) return;
    cubit.update(
      parameter: data.copyWith(offset: 0),
      mangaSectionState: cubit.state.mangaSectionState.copyWith(mangas: []),
    );
    if (data.title?.isNotEmpty == true) cubit.search();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: onChangeTitle,
          onSubmitted: (value) => context.read<SearchScreenCubit>().search(),
        ),
        actions: [
          BlocBuilder<SearchScreenCubit, SearchScreenCubitState>(
            buildWhen: (prev, curr) {
              return prev.tagsSectionState != curr.tagsSectionState;
            },
            builder: (context, state) {
              return IconButton(
                icon: ConditionalWidget(
                  value: state.tagsSectionState.isLoading,
                  otherChild: const Icon(Icons.settings),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                // icon: const Icon(Icons.sort),
                onPressed: () => !state.tagsSectionState.isLoading
                    ? _onTapFilter(tags: state.tagsSectionState.tags)
                    : null,
              );
            },
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<SearchScreenCubit, SearchScreenCubitState>(
          buildWhen: (prev, curr) {
            return prev.mangaSectionState != curr.mangaSectionState;
          },
          builder: (context, state) {
            if (state.mangaSectionState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.mangaSectionState.errorMessage?.isNotEmpty == true) {
              return Center(
                child: Text(state.mangaSectionState.errorMessage ?? ''),
              );
            }

            if (state.mangaSectionState.mangas.isEmpty) {
              return const Center(
                child: Text('Manga Empty'),
              );
            }

            final children = state.mangaSectionState.mangas.map(
              (e) => MangaGridItemWidget(
                title: e.title,
                coverUrl: e.coverUrl,
              ),
            );

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                return _scrollController.onScrollNotification(
                  context,
                  scrollNotification,
                );
              },
              child: GridView.count(
                controller: _scrollController,
                crossAxisCount: _crossAxisCount(context),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: (100 / 140),
                children: children.toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
