import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_page_view/manga_page_view.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_reader_screen_cubit.dart';
import 'manga_reader_screen_state.dart';

class MangaReaderScreen extends StatelessWidget {
  const MangaReaderScreen({
    super.key,
    required this.imagesCacheManager,
    required this.logBox,
    this.onTapShortcut,
  });

  final ImagesCacheManager imagesCacheManager;

  final LogBox logBox;

  final void Function(String)? onTapShortcut;

  static Widget create({
    required ServiceLocator locator,
    required String? source,
    required String? mangaId,
    required String? chapterId,
    void Function(String)? onTapShortcut,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaReaderScreenCubit(
          initialState: MangaReaderScreenState(
            mangaId: mangaId,
            chapterId: chapterId,
            source: source?.let((e) => SourceEnum.fromValue(name: source)),
          ),
          getChapterUseCase: locator(),
          updateChapterLastReadAtUseCase: locator(),
          listenSearchParameterUseCase: locator(),
          getAllChapterUseCase: locator(),
          recrawlUseCase: locator(),
          listenPrefetchChapterConfig: locator(),
          prefetchChapterUseCase: locator()
        )..init();
      },
      child: MangaReaderScreen(
        imagesCacheManager: locator(),
        onTapShortcut: onTapShortcut,
        logBox: locator(),
      ),
    );
  }

  MangaReaderScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaReaderScreenState> builder,
    BlocBuilderCondition<MangaReaderScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaReaderScreenCubit, MangaReaderScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: _title(), actions: [_recrawlButton()]),
      body: _content(context: context),
    );
  }

  Widget _title() {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.chapter?.chapter != curr.chapter?.chapter,
          prev.isLoading != curr.isLoading,
        ].contains(true);
      },
      builder: (context, state) {
        return ShimmerLoading.multiline(
          isLoading: state.isLoading,
          width: 100,
          height: 20,
          lines: 1,
          child: Text('Chapter ${state.chapter?.chapter}'),
        );
      },
    );
  }

  Widget _errorContent({
    required BuildContext context,
    required Exception error,
  }) {
    return Center(
      child: Column(
        children: [
          Text(error.toString(), textAlign: TextAlign.center),
          if (error is FailedParsingHtmlException) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _onTapRecrawl(context: context, url: error.url),
              child: const Text('Open Debug Browser'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _content({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.isLoading != curr.isLoading,
          prev.error != curr.error,
          prev.chapter?.images != curr.chapter?.images,
          prev.previousChapterId != curr.previousChapterId,
          prev.nextChapterId != curr.nextChapterId,
          prev.isLoadingChapterIds != curr.isLoadingChapterIds,
        ].contains(true);
      },
      builder: (context, state) {
        final error = state.error;
        final images = state.chapter?.images ?? [];
        final url = state.chapter?.webUrl;
        final prevId = state.previousChapterId;
        final nextId = state.nextChapterId;

        if (error != null) {
          return _errorContent(context: context, error: error);
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Images Empty'),
                if (url != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _onTapRecrawl(context: context, url: url),
                    child: const Text('Open Debug Browser'),
                  ),
                ],
              ],
            ),
          );
        }

        return MangaPageView(
          mode: MangaPageViewMode.continuous,
          direction: MangaPageViewDirection.down,
          pageCount: images.length,
          options: MangaPageViewOptions(
            crossAxisOverscroll: false,
            precacheAhead: 1,
            precacheBehind: 1,
            maxZoomLevel: 4,
            minZoomLevel: 1,
            edgeIndicatorContainerSize: 100,
          ),
          pageBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images.elementAt(index),
              cacheManager: imagesCacheManager,
              errorWidget: (context, url, error) {
                return SizedBox(
                  width: 100,
                  height: 100,
                  child: const Center(child: Icon(Icons.error)),
                );
              },
              progressIndicatorBuilder: (context, url, progress) {
                return SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                );
              },
            );
          },
          startEdgeDragIndicatorBuilder: (context, info) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isLoadingChapterIds) ...[
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ] else if (prevId != null) ...[
                    Icon(Icons.arrow_upward),
                    Text('Previous Chapter'),
                  ] else ...[
                    Text('No Previous Chapter'),
                  ],
                ],
              ),
            );
          },
          endEdgeDragIndicatorBuilder: (context, info) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isLoadingChapterIds) ...[
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ] else if (nextId != null) ...[
                    Icon(Icons.arrow_downward),
                    Text('Next Chapter'),
                  ] else ...[
                    Text('No Next Chapter'),
                  ],
                ],
              ),
            );
          },
          onStartEdgeDrag: () {
            if (state.isLoadingChapterIds || prevId == null) return;
            onTapShortcut?.call(prevId);
          },
          onEndEdgeDrag: () {
            if (state.isLoadingChapterIds || nextId == null) return;
            onTapShortcut?.call(nextId);
          },
        );
      },
    );
  }

  Widget _recrawlButton() {
    return _builder(
      buildWhen: (prev, curr) => prev.chapter?.webUrl != curr.chapter?.webUrl,
      builder: (context, state) {
        final url = state.chapter?.webUrl;
        if (url == null) {
          return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: () => _onTapRecrawl(context: context, url: url),
          icon: const Icon(Icons.web),
        );
      },
    );
  }

  void _onTapRecrawl({required BuildContext context, required String url}) {
    _cubit(context).recrawl(context: context, url: url);
  }
}
