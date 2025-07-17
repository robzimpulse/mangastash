import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'library_manga_screen_cubit.dart';
import 'library_manga_screen_state.dart';

class LibraryMangaScreen extends StatefulWidget {
  const LibraryMangaScreen({
    super.key,
    required this.cacheManager,
    this.onTapManga,
    this.onTapAddManga,
  });

  final ValueSetter<Manga?>? onTapManga;

  final AsyncValueGetter<String?>? onTapAddManga;

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    AsyncValueGetter<String?>? onTapAddManga,
    String? sourceId,
  }) {
    return BlocProvider(
      create: (context) => LibraryMangaScreenCubit(
        listenMangaFromLibraryUseCase: locator(),
        prefetchMangaUseCase: locator(),
        listenPrefetchMangaUseCase: locator(),
        removeFromLibraryUseCase: locator(),
        prefetchChapterUseCase: locator(),
        getMangaFromUrlUseCase: locator(),
        addToLibraryUseCase: locator(),
      ),
      child: LibraryMangaScreen(
        cacheManager: locator(),
        onTapManga: onTapManga,
        onTapAddManga: onTapAddManga,
      ),
    );
  }

  @override
  State<LibraryMangaScreen> createState() => _LibraryMangaScreenState();
}

class _LibraryMangaScreenState extends State<LibraryMangaScreen> {
  final _scrollController = ScrollController();

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
          _layoutAdd(context: context),
          _layoutRefresh(context: context),
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
      buildWhen: (prev, curr) => prev.mangas != curr.mangas,
      builder: (context, state) {
        if (state.mangas.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.cloud_download),
          onPressed: () => _cubit(context).prefetch(
            mangas: state.mangas,
          ),
        );
      },
    );
  }

  Widget _layoutSearch({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.isSearchActive != curr.isSearchActive,
      builder: (context, state) => IconButton(
        icon: Icon(state.isSearchActive ? Icons.close : Icons.search),
        onPressed: () => _cubit(context).update(
          isSearchActive: !state.isSearchActive,
        ),
      ),
    );
  }

  Widget _layoutAdd({required BuildContext context}) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final result = await widget.onTapAddManga?.call();
        if (!context.mounted || result == null) return;
        _cubit(context).add(url: result);
      },
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.filteredMangas != curr.filteredMangas,
        prev.sources != curr.sources,
        prev.prefetchedMangaIds != curr.prefetchedMangaIds,
      ].contains(true),
      builder: (context, state) => GridWidget(
        itemBuilder: (context, data) => MangaItemWidget(
          manga: data,
          cacheManager: widget.cacheManager,
          isPrefetching: state.prefetchedMangaIds.contains(data.id),
          onTap: () => widget.onTapManga?.call(data),
          onLongPress: () => _onTapMenu(
            context: context,
            manga: data,
            isOnLibrary: true,
          ),
        ),
        error: state.error,
        isLoading: state.isLoading,
        hasNext: false,
        data: state.filteredMangas,
      ),
    );
  }
}
