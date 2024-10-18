import 'package:core_network/core_network.dart';
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
    this.onTapManga,
  });

  final LaunchUrlUseCase launchUrlUseCase;

  final ValueSetter<String?>? onTapManga;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<String?>? onTapManga,
    String? sourceId,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaScreenCubit(
        initialState: BrowseMangaScreenState(
          sourceId: sourceId,
          layout: MangaShelfItemLayout.comfortableGrid,
        ),
        getMangaSourceUseCase: locator(),
        searchMangaUseCase: locator(),
      )..init(),
      child: BrowseMangaScreen(
        launchUrlUseCase: locator(),
        onTapManga: onTapManga,
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

  Widget _builder({
    required BlocWidgetBuilder<BrowseMangaScreenState> builder,
    BlocBuilderCondition<BrowseMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaScreenCubit, BrowseMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  void _onTapOpenInBrowser({
    required BuildContext context,
    MangaSource? source,
  }) async {
    final url = source?.url;

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
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BrowseMangaScreenCubit, BrowseMangaScreenState>(
            listenWhen: (prev, curr) {
              return prev.isSearchActive != curr.isSearchActive;
            },
            listener: (context, state) {
              // _searchController.clear();
              _searchFocusNode.requestFocus();
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () => _cubit(context).init(),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        final isSourceChanged = prev.source != curr.source;
        final isLoadingChanged = prev.isLoading != curr.isLoading;
        final isSearchChanged = prev.isSearchActive != curr.isSearchActive;
        return isSourceChanged || isLoadingChanged || isSearchChanged;
      },
      builder: (context, state) => !state.isSearchActive
          ? ShimmerLoading.multiline(
              isLoading: state.isLoading,
              width: 200,
              height: 15,
              lines: 1,
              child: Text(
                state.source?.name?.value ?? '',
              ),
            )
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
            title: e.title ?? '',
            coverUrl: e.coverUrl ?? '',
            layout: state.layout,
            onTap: () => widget.onTapManga?.call(e.id),
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
