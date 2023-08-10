import 'package:collection/collection.dart';
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
    required this.locator,
  });

  final ServiceLocator locator;

  static Widget create({
    required ServiceLocator locator,
    required Manga manga,
  }) {
    return BlocProvider(
      create: (context) => DetailMangaCubit(
        manga: manga,
        getAllChapterUseCase: locator(),
      )..init(),
      child: DetailMangaScreen(
        locator: locator,
      ),
    );
  }

  @override
  State<DetailMangaScreen> createState() => _DetailMangaScreenState();
}

class _DetailMangaScreenState extends State<DetailMangaScreen> {
  Widget _builder({
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
        title: _title(),
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
        child: _content(),
      ),
    );
  }

  Widget _title() {
    return _builder(
      builder: (context, state) => Text(state.manga?.title ?? ''),
    );
  }

  Widget _content() {
    return _builder(
      builder: (context, state) {
        final tags = state.manga?.tags;
        final errorMessage = state.errorMessage;
        final chapters = state.manga?.chapters;

        if (state.isLoading) {
          return MangaDetailWidget.loading(
            coverUrl: state.manga?.coverUrl,
            title: state.manga?.title,
            author: state.manga?.author,
            status: state.manga?.status,
            description: state.manga?.description,
            tags: tags?.map((e) => e.name).whereNotNull().toList(),
            horizontalPadding: 12,
            onTapFavorite: () => context.showSnackBar(
              message: 'on tap favorite',
            ),
            onTapWebsite: () => context.showSnackBar(
              message: 'on tap website',
            ),
            onTapTag: (name) => context.showSnackBar(
              message: 'on tap tag $name',
            ),
          );
        }

        if (errorMessage != null) {
          return MangaDetailWidget.message(
            coverUrl: state.manga?.coverUrl,
            title: state.manga?.title,
            author: state.manga?.author,
            status: state.manga?.status,
            description: state.manga?.description,
            tags: tags?.map((e) => e.name).whereNotNull().toList(),
            horizontalPadding: 12,
            onTapFavorite: () => context.showSnackBar(
              message: 'on tap favorite',
            ),
            onTapWebsite: () => context.showSnackBar(
              message: 'on tap website',
            ),
            onTapTag: (name) => context.showSnackBar(
              message: 'on tap tag $name',
            ),
            message: errorMessage,
          );
        }

        if (chapters != null) {
          return MangaDetailWidget.content(
            coverUrl: state.manga?.coverUrl,
            title: state.manga?.title,
            author: state.manga?.author,
            status: state.manga?.status,
            description: state.manga?.description,
            tags: tags?.map((e) => e.name).whereNotNull().toList(),
            horizontalPadding: 12,
            onTapFavorite: () => context.showSnackBar(
              message: 'on tap favorite',
            ),
            onTapWebsite: () => context.showSnackBar(
              message: 'on tap website',
            ),
            onTapTag: (name) => context.showSnackBar(
              message: 'on tap tag $name',
            ),
            chapterCount: chapters.length,
            chapterForIndex: (context, index) => ListTile(
              title: Text(chapters[index].top),
              subtitle: Text(chapters[index].bottom),
              onTap: () => context.showSnackBar(
                message: 'on tap chapter id ${chapters[index].id}',
              ),
            ),
          );
        }

        return MangaDetailWidget.message(
          coverUrl: state.manga?.coverUrl,
          title: state.manga?.title,
          author: state.manga?.author,
          status: state.manga?.status,
          description: state.manga?.description,
          tags: tags?.map((e) => e.name).whereNotNull().toList(),
          horizontalPadding: 12,
          onTapFavorite: () => context.showSnackBar(
            message: 'on tap favorite',
          ),
          onTapWebsite: () => context.showSnackBar(
            message: 'on tap website',
          ),
          onTapTag: (name) => context.showSnackBar(
            message: 'on tap tag $name',
          ),
          message: 'No Chapter Found',
        );
      },
    );
  }
}
