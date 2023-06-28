import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'home_cubit.dart';
import 'home_cubit_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) => HomeCubit(
        searchMangaUseCase: locator(),
      ),
      child: const HomeScreen(),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().initialize();
  }

  int _crossAxisCount(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    if (responsive.isPhone || responsive.isMobile) return 3;
    if (responsive.isTablet) return 6;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push('/favourite'),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<HomeCubit, HomeCubitState>(
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
