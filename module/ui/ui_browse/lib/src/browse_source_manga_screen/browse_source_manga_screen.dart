import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_manga_screen_cubit.dart';

class BrowseSourceMangaScreen extends StatelessWidget {
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
      create: (context) => BrowseSourceMangaScreenCubit(),
      child: BrowseSourceMangaScreen(
        title: title,
        url: url,
      ),
    );
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
      body: Center(
        child: Text('Browse Source at $url'),
      ),
    );
  }
}
