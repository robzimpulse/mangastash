import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'search_screen_cubit.dart';
import 'search_screen_cubit_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) => SearchScreenCubit(
        searchMangaUseCase: locator(),
      ),
      child: const SearchScreen(),
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final _debounceSearch = Debounce(delay: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceSearch.dispose();
    super.dispose();
  }

  int _crossAxisCount(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    if (responsive.isPhone || responsive.isMobile) return 3;
    if (responsive.isTablet) return 6;
    return 8;
  }

  void _onSearch(String value) {
    _debounceSearch.call(
      () {
        if (!mounted) return;
        context.read<SearchScreenCubit>().search(value);
      },
    );
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
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => {},
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<SearchScreenCubit, SearchScreenCubitState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.errorMessage?.isNotEmpty == true) {
              return Center(
                child: Text(state.errorMessage ?? ''),
              );
            }

            if (state.mangas.isEmpty) {
              return const Center(
                child: Text('Manga Empty'),
              );
            }

            return GridView.count(
              crossAxisCount: _crossAxisCount(context),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: (100 / 140),
              children: state.mangas
                  .map(
                    (e) => MangaGridItemWidget(
                      title: e.title,
                      coverUrl: e.coverUrl,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
