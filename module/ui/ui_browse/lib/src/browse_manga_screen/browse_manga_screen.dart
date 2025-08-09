import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:super_paging/super_paging.dart';

import 'browse_manga_screen_cubit.dart';
import 'browse_manga_screen_state.dart';

class BrowseMangaScreen extends StatefulWidget {
  const BrowseMangaScreen({
    super.key,
    required this.storageManager,
    this.onTapManga,
    this.onTapFilter,
  });

  final Function(Manga, SearchMangaParameter?)? onTapManga;

  final Future<SearchMangaParameter?>? Function(
    SearchMangaParameter? value,
    List<Tag> availableTags,
  )?
  onTapFilter;

  final StorageManager storageManager;

  static Widget create({
    required ServiceLocator locator,
    Function(Manga, SearchMangaParameter?)? onTapManga,
    Future<SearchMangaParameter?>? Function(
      SearchMangaParameter? value,
      List<Tag> availableTags,
    )?
    onTapFilter,
    String? source,
  }) {
    return BlocProvider(
      create: (context) {
        return BrowseMangaScreenCubit(
          initialState: BrowseMangaScreenState(
            source: source?.let((e) => SourceEnum.fromValue(name: source)),
          ),
          searchMangaUseCase: locator(),
          listenMangaFromLibraryUseCase: locator(),
          addToLibraryUseCase: locator(),
          removeFromLibraryUseCase: locator(),
          prefetchMangaUseCase: locator(),
          listenPrefetchMangaUseCase: locator(),
          prefetchChapterUseCase: locator(),
          listenSearchParameterUseCase: locator(),
          getTagsUseCase: locator(),
        )..init();
      },
      child: BrowseMangaScreen(
        storageManager: locator(),
        onTapManga: onTapManga,
        onTapFilter: onTapFilter,
      ),
    );
  }

  @override
  State<BrowseMangaScreen> createState() => _BrowseMangaScreenState();
}

class _BrowseMangaScreenState extends State<BrowseMangaScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  late final pager = Pager(
    initialKey: const SearchMangaParameter(), // Initial page to load.
    config: const PagingConfig(pageSize: 20, initialLoadSize: 60),
    pagingSourceFactory: () => _cubit(context).dataSource,
  );

  @override
  void dispose() {
    pager.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  BrowseMangaScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<BrowseMangaScreenState> builder,
    BlocBuilderCondition<BrowseMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaScreenCubit, BrowseMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  BlocConsumer _consumer({
    required BlocWidgetBuilder<BrowseMangaScreenState> builder,
    BlocBuilderCondition<BrowseMangaScreenState>? buildWhen,
    required BlocWidgetListener<BrowseMangaScreenState> listener,
    BlocListenerCondition<BrowseMangaScreenState>? listenWhen,
  }) {
    return BlocConsumer<BrowseMangaScreenCubit, BrowseMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
      listener: listener,
      listenWhen: listenWhen,
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
        _cubit(context).addToLibrary(manga: manga);
      case MangaMenu.prefetch:
        _cubit(context).prefetch(manga: manga);
    }
  }

  Widget _menuSource({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.source != curr.source,
          prev.parameter != curr.parameter,
        ].contains(true);
      },
      builder: (context, state) {
        final parameter = state.parameter.copyWith(page: 1);
        final source = state.source;
        final url =
            source == SourceEnum.mangaclash
                ? parameter.mangaclash
                : source == SourceEnum.asurascan
                ? parameter.asurascan
                : null;

        if (url == null) return const SizedBox.shrink();

        return IconButton(
          icon: const Icon(Icons.open_in_browser),
          onPressed: () {
            context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
          },
        );
      },
    );
  }

  Widget _menuSearch({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder:
          (context, state) => IconButton(
            icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
            onPressed:
                () => _cubit(
                  context,
                ).update(isSearchActive: !state.isSearchActive),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(context),
        actions: [_menuSearch(context: context), _menuSource(context: context)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 44),
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: _menus(context),
            ),
          ),
        ),
      ),
      body: _content(context),
    );
  }

  Widget _menus(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.appBarTheme.iconTheme?.color;
    final labelStyle = theme.textTheme.labelSmall;
    final buttonStyle = theme.outlinedButtonTheme.style?.copyWith(
      visualDensity: VisualDensity.compact,
      side: WidgetStatePropertyAll(
        const BorderSide(width: 1).copyWith(color: color),
      ),
    );

    final List<Widget> menus = [
      _builder(
        buildWhen: (prev, curr) {
          return [
            prev.isFavoriteActive != curr.isFavoriteActive,
            prev.parameter != curr.parameter,
          ].contains(true);
        },
        builder: (context, state) {
          return IconButton.outlined(
            style: buttonStyle?.copyWith(
              backgroundColor:
                  state.isFavoriteActive
                      ? const WidgetStatePropertyAll(Colors.grey)
                      : null,
            ),
            icon: Icon(Icons.favorite, color: color),
            onPressed: () {
              _cubit(context).init(
                parameter: state.parameter.copyWith(
                  orders: Map.fromEntries([
                    MapEntry(
                      state.isFavoriteActive
                          ? SearchOrders.relevance
                          : SearchOrders.rating,
                      OrderDirections.descending,
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
      _builder(
        buildWhen: (prev, curr) {
          return [
            prev.isUpdatedActive != curr.isUpdatedActive,
            prev.parameter != curr.parameter,
          ].contains(true);
        },
        builder: (context, state) {
          return IconButton.outlined(
            style: buttonStyle?.copyWith(
              backgroundColor:
                  state.isUpdatedActive
                      ? const WidgetStatePropertyAll(Colors.grey)
                      : null,
            ),
            icon: Icon(Icons.update, color: color),
            onPressed: () {
              _cubit(context).init(
                parameter: state.parameter.copyWith(
                  orders: Map.fromEntries([
                    MapEntry(
                      state.isUpdatedActive
                          ? SearchOrders.relevance
                          : SearchOrders.updatedAt,
                      OrderDirections.descending,
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
      _builder(
        buildWhen: (prev, curr) {
          return [
            prev.parameter != curr.parameter,
            prev.isFilterActive != curr.isFilterActive,
            prev.tags != curr.tags,
          ].contains(true);
        },
        builder: (context, state) {
          return OutlinedButton.icon(
            style: buttonStyle?.copyWith(
              backgroundColor:
                  state.isFilterActive
                      ? const WidgetStatePropertyAll(Colors.grey)
                      : null,
            ),
            icon: Icon(Icons.filter_list, color: color),
            label: Text('Filter', style: labelStyle?.copyWith(color: color)),
            onPressed: () async {
              final result = await widget.onTapFilter?.call(
                state.parameter,
                state.tags,
              );
              if (context.mounted && result != null) {
                _cubit(context).init(parameter: result);
              }
            },
          );
        },
      ),
    ];

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: menus.intersperse(const SizedBox(width: 4)).toList(),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return _consumer(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) {
        state.isSearchActive
            ? _searchFocusNode.requestFocus()
            : _searchFocusNode.unfocus();
        _cubit(context).init(
          parameter: state.parameter.copyWith(
            title: state.isSearchActive ? _searchController.text : '',
          ),
        );
      },
      buildWhen: (prev, curr) {
        return [
          prev.source != curr.source,
          prev.isSearchActive != curr.isSearchActive,
          prev.parameter != curr.parameter,
        ].contains(true);
      },
      builder: (context, state) {
        if (state.isSearchActive) {
          return Container(
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
              onSubmitted:
                  (value) => _cubit(
                    context,
                  ).init(parameter: state.parameter.copyWith(title: value)),
            ),
          );
        }

        return Text(state.source?.name ?? '');
      },
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.parameter != curr.parameter,
          prev.source != curr.source,
          prev.libraryMangaIds != curr.libraryMangaIds,
          prev.prefetchedMangaIds != curr.prefetchedMangaIds,
        ].contains(true);
      },
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: PagingSliverGrid(
                pager: pager,
                itemBuilder: (BuildContext context, int index) {
                  final data = pager.items.elementAt(index);

                  return MangaItemWidget(
                    manga: data,
                    cacheManager: widget.storageManager.images,
                    onTap: () {
                      widget.onTapManga?.call(data, pager.page(index));
                    },
                    onLongPress: () {
                      _onTapMenu(
                        context: context,
                        manga: data,
                        isOnLibrary: state.libraryMangaIds.contains(data.id),
                      );
                    },
                    isOnLibrary: state.libraryMangaIds.contains(data.id),
                    isPrefetching: state.prefetchedMangaIds.contains(data.id),
                  );
                },
                emptyBuilder: (BuildContext context) {
                  return const Center(child: Text('No characters found'));
                },
                errorBuilder: (BuildContext context, Object? error) {
                  return Center(child: Text('$error'));
                },
                loadingBuilder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 100 / 140,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
