import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'detail_manga_cubit.dart';
import 'detail_manga_state.dart';

class DetailMangaScreen extends StatefulWidget {
  const DetailMangaScreen({
    super.key,
    required this.manga,
    required this.locator,
  });

  final Manga manga;

  final ServiceLocator locator;

  static Widget create({
    required ServiceLocator locator,
    required Manga manga,
  }) {
    return BlocProvider(
      create: (context) => DetailMangaCubit(
        manga: manga,
        getMangaUseCase: locator(),
      )..init(),
      child: DetailMangaScreen(
        locator: locator,
        manga: manga,
      ),
    );
  }

  @override
  State<DetailMangaScreen> createState() => _DetailMangaScreenState();
}

class _DetailMangaScreenState extends State<DetailMangaScreen> {
  Widget _bloc({
    required BlocWidgetBuilder<DetailMangaState> builder,
    BlocBuilderCondition<DetailMangaState>? buildWhen,
  }) {
    return BlocBuilder<DetailMangaCubit, DetailMangaState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  DetailMangaCubit _cubit(BuildContext context) {
    return context.read<DetailMangaCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: Text(widget.manga.title ?? ''),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _cubit(context).init(),
        child: _bloc(
          builder: (context, state) => _content(),
        ),
      ),
    );
  }

  Widget _content() {
    return _bloc(
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

        return MangaDetailWidget(
          coverUrl: widget.manga.coverUrl,
          title: widget.manga.title,
          author: 'Author',
          status: 'Status',
          description: 'Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded Expanded '
              'Expanded Expanded Expanded Expanded Expanded ',
        );
      },
    );
  }
}
