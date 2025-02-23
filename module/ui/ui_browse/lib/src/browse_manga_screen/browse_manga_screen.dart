import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_screen_cubit.dart';
import 'browse_manga_screen_state.dart';

class BrowseMangaScreen extends StatefulWidget {
  const BrowseMangaScreen({
    super.key,
    required this.launchUrlUseCase,
    required this.getMangaSourceUseCase,
    this.onTapManga,
    this.onTapFilter,
    this.cacheManager,
  });

  final LaunchUrlUseCase launchUrlUseCase;

  final ValueSetter<String?>? onTapManga;

  final Future<SearchMangaParameter?>? Function(
    SearchMangaParameter? value,
  )? onTapFilter;

  final BaseCacheManager? cacheManager;

  final GetMangaSourceUseCase getMangaSourceUseCase;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<String?>? onTapManga,
    Future<SearchMangaParameter?>? Function(
      SearchMangaParameter? value,
    )? onTapFilter,
    MangaSourceEnum? source,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaScreenCubit(
        initialState: BrowseMangaScreenState(
          source: source,
          layout: MangaShelfItemLayout.comfortableGrid,
        ),
        getMangaSourceUseCase: locator(),
        searchMangaUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
      )..init(),
      child: BrowseMangaScreen(
        launchUrlUseCase: locator(),
        cacheManager: locator(),
        getMangaSourceUseCase: locator(),
        onTapManga: onTapManga,
        onTapFilter: onTapFilter,
      ),
    );
  }

  @override
  State<BrowseMangaScreen> createState() => _BrowseMangaScreenState();
}

class _BrowseMangaScreenState extends State<BrowseMangaScreen> {
  late final PagingScrollController _scrollController = PagingScrollController(
    onLoadNextPage: (context) => _cubit(context).next(),
  );

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  BrowseMangaScreenCubit _cubit(BuildContext context) => context.read();

  int _crossAxisCount(BuildContext context) {
    if (_breakpoints(context).isMobile) return 3;
    if (_breakpoints(context).isTablet) return 5;
    if (_breakpoints(context).isDesktop) return 8;
    return 12;
  }

  ResponsiveBreakpointsData _breakpoints(BuildContext context) {
    return ResponsiveBreakpoints.of(context);
  }

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

  void _onTapOpenInBrowser({
    required BuildContext context,
    MangaSourceEnum? source,
  }) async {
    if (source == null) {
      context.showSnackBar(message: 'Could not launch source url');
      return;
    }

    final url = widget.getMangaSourceUseCase.get(source)?.url;

    if (url == null || url.isEmpty) {
      context.showSnackBar(message: 'Could not launch source url');
      return;
    }

    final result = await widget.launchUrlUseCase.launch(
      url: url,
      mode: LaunchMode.externalApplication,
    );

    if (result || !context.mounted) return;
    context.showSnackBar(message: 'Could not launch $url');
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

  Widget _layoutSource({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.source != curr.source,
      builder: (context, state) => IconButton(
        icon: const Icon(Icons.open_in_browser),
        onPressed: () => _onTapOpenInBrowser(
          context: context,
          source: state.source,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(context),
        actions: [
          _layoutSearch(context: context),
          _layoutIcon(context: context),
          _layoutSource(context: context),
        ],
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
      body: RefreshIndicator(
        onRefresh: () => _cubit(context).init(),
        child: _content(context),
      ),
    );
  }

  Widget _menus(BuildContext context) {
    final color = Theme.of(context).appBarTheme.iconTheme?.color;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final buttonStyle = OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      side: const BorderSide(width: 1).copyWith(color: color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Wrap(
      spacing: 4,
      children: [
        _builder(
          buildWhen: (prev, curr) => [
            prev.isFavoriteActive != curr.isFavoriteActive,
          ].any((e) => e),
          builder: (context, state) => OutlinedButton.icon(
            style: buttonStyle.copyWith(
              backgroundColor: state.isFavoriteActive
                  ? const WidgetStatePropertyAll(Colors.grey)
                  : null,
            ),
            icon: Icon(Icons.favorite, color: color),
            label: Text('Favorite', style: labelStyle?.copyWith(color: color)),
            onPressed: () => _cubit(context).init(order: SearchOrders.rating),
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.isUpdatedActive != curr.isUpdatedActive,
          ].any((e) => e),
          builder: (context, state) => OutlinedButton.icon(
            style: buttonStyle.copyWith(
              backgroundColor: state.isUpdatedActive
                  ? const WidgetStatePropertyAll(Colors.grey)
                  : null,
            ),
            icon: Icon(Icons.update, color: color),
            label: Text('Updated', style: labelStyle?.copyWith(color: color)),
            onPressed: () => _cubit(context).init(
              order: SearchOrders.updatedAt,
            ),
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => prev.parameter != curr.parameter,
          builder: (context, state) => OutlinedButton.icon(
            style: buttonStyle,
            icon: Icon(Icons.filter_list, color: color),
            label: Text('Filter', style: labelStyle?.copyWith(color: color)),
            onPressed: () async {
              final result = await widget.onTapFilter?.call(state.parameter);
              if (context.mounted && result != null) {
                context.showSnackBar(
                  message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return _consumer(
      listenWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      listener: (context, state) => _searchFocusNode.requestFocus(),
      buildWhen: (prev, curr) => [
        prev.source != curr.source,
        prev.isSearchActive != curr.isSearchActive,
      ].any((e) => e),
      builder: (context, state) => !state.isSearchActive
          ? Text(state.source?.value ?? '')
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
                onSubmitted: (value) => _cubit(context).init(title: value),
              ),
            ),
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
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

        if (state.mangas.isEmpty) {
          return const Center(
            child: Text('Manga Empty'),
          );
        }

        final children = state.mangas.map(
          (e) => MangaShelfItem(
            cacheManager: widget.cacheManager,
            title: e.title ?? '',
            coverUrl: e.coverUrl ?? '',
            layout: state.layout,
            onTap: () => widget.onTapManga?.call(e.id),
            isOnLibrary: state.libraryMapById[e.id] != null,
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
              hasNextPage: state.hasNextPage,
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
              hasNextPage: state.hasNextPage,
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
              hasNextPage: state.hasNextPage,
              loadingIndicator: indicator,
              separator: const Divider(height: 1, thickness: 1),
              children: children.toList(),
            );
        }
      },
    );
  }
}
