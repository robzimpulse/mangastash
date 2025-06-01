import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'library_manga_screen_cubit.dart';
import 'library_manga_screen_state.dart';

class LibraryMangaScreen extends StatefulWidget {
  const LibraryMangaScreen({
    super.key,
    this.onTapManga,
    this.cacheManager,
  });

  final ValueSetter<Manga?>? onTapManga;

  final BaseCacheManager? cacheManager;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    String? sourceId,
  }) {
    return BlocProvider(
      create: (context) => LibraryMangaScreenCubit(
        initialState: LibraryMangaScreenState(),
        listenMangaFromLibraryUseCase: locator(),
        listenMangaSourceUseCase: locator(),
        prefetchMangaUseCase: locator(),
        listenPrefetchMangaUseCase: locator(),
        removeFromLibraryUseCase: locator(),
        downloadMangaUseCase: locator(),
      ),
      child: LibraryMangaScreen(
        cacheManager: locator(),
        onTapManga: onTapManga,
      ),
    );
  }

  @override
  State<LibraryMangaScreen> createState() => _LibraryMangaScreenState();
}

class _LibraryMangaScreenState extends State<LibraryMangaScreen> {
  final _scrollController = PagingScrollController(
    onLoadNextPage: (context) {},
  );

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  LibraryMangaScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<LibraryMangaScreenState> builder,
    BlocBuilderCondition<LibraryMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<LibraryMangaScreenCubit, LibraryMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  BlocConsumer _consumer({
    required BlocWidgetBuilder<LibraryMangaScreenState> builder,
    BlocBuilderCondition<LibraryMangaScreenState>? buildWhen,
    required BlocWidgetListener<LibraryMangaScreenState> listener,
    BlocListenerCondition<LibraryMangaScreenState>? listenWhen,
  }) {
    return BlocConsumer<LibraryMangaScreenCubit, LibraryMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(context: context),
        actions: [
          _layoutSearch(context: context),
          _layoutRefresh(context: context),
          _layoutIcon(context: context),
        ],
      ),
      body: _content(context),
    );
  }

  void _onTapMenu({
    required BuildContext context,
    required Manga manga,
    required bool isOnLibrary,
  }) async {
    final result = await context.pushNamed<MangaMenu>(
      CommonRoutePath.menu,
      queryParameters: {
        CommonRoutePath.menuIsOnLibrary: isOnLibrary ? 'true' : 'false',
      },
    );

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

  ResponsiveBreakpointsData _breakpoints(BuildContext context) {
    return ResponsiveBreakpoints.of(context);
  }

  int _crossAxisCount(BuildContext context) {
    if (_breakpoints(context).isMobile) return 3;
    if (_breakpoints(context).isTablet) return 5;
    if (_breakpoints(context).isDesktop) return 8;
    return 12;
  }

  Widget _title({required BuildContext context}) {
    return _consumer(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) => _searchFocusNode.requestFocus(),
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) => !state.isSearchActive
          ? const Text('Library')
          : Container(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: false,
                  border: InputBorder.none,
                  hintStyle: DefaultTextStyle.of(context).style,
                ),
                cursorColor: DefaultTextStyle.of(context).style.color,
                style: DefaultTextStyle.of(context).style,
                onChanged: (value) => _cubit(context).update(
                  mangaTitle: value,
                ),
                onSubmitted: (value) => _cubit(context).update(
                  mangaTitle: value,
                ),
              ),
            ),
    );
  }

  Widget _layoutRefresh({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.filteredMangas != curr.filteredMangas,
      builder: (context, state) {
        if (state.filteredMangas.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.cloud_download),
          onPressed: () => _cubit(context).prefetch(
            mangas: state.filteredMangas,
          ),
        );
      },
    );
  }

  Widget _layoutSearch({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
          onPressed: () => _cubit(context).update(
            isSearchActive: !state.isSearchActive,
          ),
        );
      },
    );
  }

  Widget _layoutIcon({required BuildContext context}) {
    return PopupMenuButton<MangaShelfItemLayout>(
      icon: _builder(
        buildWhen: (prev, curr) => prev.layout != curr.layout,
        builder: (context, state) {
          switch (state.layout) {
            case MangaShelfItemLayout.comfortableGrid:
              return const Icon(Icons.grid_view_sharp);
            case MangaShelfItemLayout.compactGrid:
              return const Icon(Icons.grid_on);
            case MangaShelfItemLayout.list:
              return const Icon(Icons.list);
          }
        },
      ),
      itemBuilder: (context) {
        final options = MangaShelfItemLayout.values.map(
          (e) => PopupMenuItem<MangaShelfItemLayout>(
            value: e,
            child: Text(e.rawValue),
          ),
        );

        return options.toList();
      },
      onSelected: (value) => _cubit(context).update(layout: value),
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.filteredMangas != curr.filteredMangas,
        prev.sources != curr.sources,
        prev.layout != curr.layout,
        prev.prefetchedMangaIds != curr.prefetchedMangaIds,
      ].contains(true),
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.error != null) {
          return Center(
            child: Text(
              state.error.toString(),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state.filteredMangas.isEmpty) {
          return const Center(
            child: Text('Manga Empty'),
          );
        }

        final children = state.filteredMangas.map(
          (e) => MangaShelfItem(
            cacheManager: widget.cacheManager,
            title: e.title ?? '',
            coverUrl: e.coverUrl ?? '',
            sourceIconUrl: state.sources[e.source]?.iconUrl,
            isPrefetching: state.prefetchedMangaIds.contains(e.id),
            layout: state.layout,
            onTap: () => widget.onTapManga?.call(e),
            onLongPress: () => _onTapMenu(
              context: context,
              manga: e,
              isOnLibrary: true,
            ),
          ),
        );

        const indicator = Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );

        switch (state.layout) {
          case MangaShelfItemLayout.comfortableGrid:
            return MangaShelfWidget.comfortableGrid(
              controller: _scrollController,
              hasNextPage: false,
              loadingIndicator: indicator,
              crossAxisCount: _crossAxisCount(context),
              childAspectRatio: (100 / 140),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: children.toList(),
            );
          case MangaShelfItemLayout.compactGrid:
            return MangaShelfWidget.compactGrid(
              controller: _scrollController,
              hasNextPage: false,
              loadingIndicator: indicator,
              crossAxisCount: _crossAxisCount(context),
              childAspectRatio: (100 / 140),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: children.toList(),
            );
          case MangaShelfItemLayout.list:
            return MangaShelfWidget.list(
              padding: const EdgeInsets.symmetric(vertical: 8),
              controller: _scrollController,
              hasNextPage: false,
              loadingIndicator: indicator,
              separator: const Divider(height: 1, thickness: 1),
              children: children.toList(),
            );
        }
      },
    );
  }
}
