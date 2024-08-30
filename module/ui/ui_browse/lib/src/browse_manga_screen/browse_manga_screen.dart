import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_cubit.dart';
import 'browse_manga_state.dart';

class BrowseMangaScreen extends StatefulWidget {
  const BrowseMangaScreen({
    super.key,
    required this.launchUrlUseCase,
  });

  final LaunchUrlUseCase launchUrlUseCase;

  static Widget create({
    required ServiceLocator locator,
    String? id,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaCubit(
        initialState: BrowseMangaState(
          sourceId: id,
          layout: MangaShelfItemLayout.comfortableGrid,
        ),
        getMangaSourceUseCase: locator(),
        addOrUpdateMangaUseCase: locator(),
        searchMangaUseCase: locator(),
      )..init(),
      child: BrowseMangaScreen(
        launchUrlUseCase: locator(),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  BrowseMangaCubit _cubit(BuildContext context) {
    return context.read();
  }

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
    required BlocWidgetBuilder<BrowseMangaState> builder,
    BlocBuilderCondition<BrowseMangaState>? buildWhen,
  }) {
    return BlocBuilder<BrowseMangaCubit, BrowseMangaState>(
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

    if (result || !mounted) return;
    context.showSnackBar(message: 'Could not launch $url');
  }

  Widget _layoutIcon({required BuildContext context}) {
    return PopupMenuButton<MangaShelfItemLayout>(
      icon: _builder(
        buildWhen: (prev, curr) => prev.layout != curr.layout,
        builder: (context, state) {
          switch (state.layout) {
            case MangaShelfItemLayout.comfortableGrid:
              return const Icon(Icons.grid_on);
            case MangaShelfItemLayout.compactGrid:
              return const Icon(Icons.grid_view_sharp);
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: _title(context),
        actions: [
          _layoutIcon(context: context),
          _layoutSource(context: context),
        ],
      ),
      body: BlocBuilder<BrowseMangaCubit, BrowseMangaState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: () => _cubit(context).init(),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) =>
          prev.source != curr.source || prev.isLoading != curr.isLoading,
      builder: (context, state) => ShimmerLoading.multiline(
        isLoading: state.isLoading,
        width: 200,
        height: 15,
        lines: 1,
        child: Text(state.source?.name ?? ''),
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
