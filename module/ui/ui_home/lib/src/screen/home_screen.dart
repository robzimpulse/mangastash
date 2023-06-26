import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import '../widget/manga_grid_item_widget.dart';
import 'home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (context) => HomeCubit(
        searchService: locator(),
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
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
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
        body: Container(
          padding: const EdgeInsets.all(10),
          child: GridView.count(
            crossAxisCount: _crossAxisCount(context),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (100 / 140),
            // TODO: fill with data from api
            children: const [
              MangaGridItemWidget(
                title: 'Test Title',
                coverUrl: '',
              )
            ],
          ),
        ),
      ),
    );
  }
}
