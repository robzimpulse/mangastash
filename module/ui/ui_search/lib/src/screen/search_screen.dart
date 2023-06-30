import 'package:data_manga/data_manga.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import '../widget/sort_bottom_sheet/sort_bottom_sheet.dart';
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
        listTagUseCase: locator(),
      ),
      child: SearchScreen(locator: locator),
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final _debounceSearch = Debounce(delay: const Duration(seconds: 1));

  @override
  void initState() {
    context.read<SearchScreenCubit>().initialize();
    super.initState();
  }

  @override
  void dispose() {
    _debounceSearch.dispose();
    super.dispose();
  }

  int _crossAxisCount(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    if (responsive.isMobile) return 3;
    if (responsive.isTablet) return 5;
    if (responsive.isDesktop) return 8;
    return 12;
  }

  void _onSearch(String value) {
    _debounceSearch.call(
      () {
        if (!mounted) return;
        context.read<SearchScreenCubit>().search(value);
      },
    );
  }

  void _onTapFilter({required List<Tag> tags}) async {
    final data = await context.showBottomSheet(
      builder: (context) => SortBottomSheet.create(
        locator: widget.locator,
        tags: tags,
      ),
    );
    if (!mounted) return;
    context.showSnackBar(message: 'data bottom sheet: $data');
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
          onChanged: _onSearch,
          onSubmitted: (value) {},
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
                  otherChild: const Icon(Icons.sort),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                // icon: const Icon(Icons.sort),
                onPressed: () => state.tagsSectionState.isLoading
                    ? null
                    : _onTapFilter(
                        tags: state.tagsSectionState.tags,
                      ),
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

            return GridView.count(
              crossAxisCount: _crossAxisCount(context),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: (100 / 140),
              children: children.toList(),
            );
          },
        ),
      ),
    );
  }
}
