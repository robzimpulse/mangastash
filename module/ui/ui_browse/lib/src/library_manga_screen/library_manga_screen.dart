import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
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
        actions: [_layoutSearch(context: context)],
      ),
      body: _content(context),
    );
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

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => prev.filteredMangas != curr.filteredMangas,
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
            layout: MangaShelfItemLayout.comfortableGrid,
            onTap: () => widget.onTapManga?.call(e),
          ),
        );

        const indicator = Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );

        return MangaShelfWidget.comfortableGrid(
          controller: _scrollController,
          loadingIndicator: indicator,
          crossAxisCount: _crossAxisCount(context),
          childAspectRatio: (100 / 140),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          hasNextPage: false,
          children: children.toList(),
        );
      },
    );
  }
}
