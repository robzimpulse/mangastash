import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import '../../search_manga_screen/search_manga_screen_cubit.dart';
import 'manga_grid_widget_cubit.dart';
import 'manga_grid_widget_state.dart';

class MangaGridWidget extends StatefulWidget {
  static Widget create({
    Key? key,
    required ServiceLocator locator,
    required SearchMangaScreenCubit parent,
    SourceEnum? source,
    void Function(Manga, SearchMangaParameter)? onTapManga,
    Future<MangaMenu?> Function(bool)? onTapMangaMenu,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaGridWidgetCubit(
          initialState: MangaGridWidgetState(source: source),
          parentCubit: parent,
          searchMangaUseCase: locator(),
          listenMangaFromLibraryUseCase: locator(),
          listenPrefetchMangaUseCase: locator(),
          listenSearchParameterUseCase: locator(),
          recrawlUseCase: locator(),
          prefetchChapterUseCase: locator(),
          prefetchMangaUseCase: locator(),
          removeFromLibraryUseCase: locator(),
        )..init();
      },
      child: MangaGridWidget._(
        key: key,
        imagesCacheManager: locator(),
        onTapManga: onTapManga,
        onTapMangaMenu: onTapMangaMenu,
      ),
    );
  }

  final ImagesCacheManager imagesCacheManager;

  final Function(Manga, SearchMangaParameter)? onTapManga;

  final Future<MangaMenu?> Function(bool)? onTapMangaMenu;

  const MangaGridWidget._({
    super.key,
    required this.imagesCacheManager,
    this.onTapManga,
    this.onTapMangaMenu,
  });

  @override
  State<MangaGridWidget> createState() => _MangaGridWidgetState();
}

class _MangaGridWidgetState extends State<MangaGridWidget> {
  MangaGridWidgetCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaGridWidgetState> builder,
    BlocBuilderCondition<MangaGridWidgetState>? buildWhen,
  }) {
    return BlocBuilder<MangaGridWidgetCubit, MangaGridWidgetState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  void _onTapMenu({
    required BuildContext context,
    required Manga manga,
    required bool isOnLibrary,
  }) async {
    final result = await widget.onTapMangaMenu?.call(isOnLibrary);

    if (result == null || !context.mounted) return;

    switch (result) {
      case MangaMenu.download:
        _cubit(context).download(manga: manga);
      case MangaMenu.library:
        _cubit(context).remove(manga: manga);
      case MangaMenu.prefetch:
        _cubit(context).prefetch(mangas: [manga]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.isLoading != curr.isLoading,
          prev.error != curr.error,
          prev.mangas != curr.mangas,
          prev.libraryMangaIds != curr.libraryMangaIds,
          prev.parameter != curr.parameter,
          prev.prefetchedMangaIds != curr.prefetchedMangaIds,
          prev.hasNextPage != curr.hasNextPage,
          prev.parameter != curr.parameter,
        ].contains(true);
      },
      builder: (context, state) {
        return GridWidget<Manga>(
          pageStorageKey: PageStorageKey('manga-grid-widget-${state.source}'),
          itemBuilder: (context, data) {
            return MangaItemWidget(
              manga: data,
              cacheManager: widget.imagesCacheManager,
              isOnLibrary: state.libraryMangaIds.contains(data.id),
              isPrefetching: state.prefetchedMangaIds.contains(data.id),
              onTap: () => widget.onTapManga?.call(data, state.parameter),
              onLongPress: () {
                _onTapMenu(
                  context: context,
                  manga: data,
                  isOnLibrary: state.libraryMangaIds.contains(data.id),
                );
              },
            );
          },
          onLoadNextPage: () => _cubit(context).next(),
          onRefresh: () => _cubit(context).init(refresh: true),
          onTapRecrawl: (url) {
            _cubit(context).recrawl(context: context, url: url);
          },
          error: state.error,
          isLoading: state.isLoading,
          hasNext: state.hasNextPage,
          data: state.mangas,
        );
      },
    );
  }
}
