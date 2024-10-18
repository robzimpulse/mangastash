import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'library_manga_screen_cubit.dart';
import 'library_manga_screen_state.dart';

class LibraryMangaScreen extends StatelessWidget {
  const LibraryMangaScreen({
    super.key,
    this.onTapManga,
  });

  final ValueSetter<Manga?>? onTapManga;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    String? sourceId,
  }) {
    return BlocProvider(
      create: (context) => LibraryMangaScreenCubit(
        initialState: const LibraryMangaScreenState(),
        listenMangaFromLibraryUseCase: locator(),
        listenAuthUseCase: locator(),
      ),
      child: LibraryMangaScreen(
        onTapManga: onTapManga,
      ),
    );
  }

  Widget _builder({
    required BlocWidgetBuilder<LibraryMangaScreenState> builder,
    BlocBuilderCondition<LibraryMangaScreenState>? buildWhen,
  }) {
    return BlocBuilder<LibraryMangaScreenCubit, LibraryMangaScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Library'),
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
            layout: MangaShelfItemLayout.comfortableGrid,
            onTap: () => onTapManga?.call(e),
          ),
        );

        const indicator = Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );

        return MangaShelfWidget.comfortableGrid(
          controller: PagingScrollController(onLoadNextPage: (context) {}),
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
