import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
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
    this.onTapImageMenu,
  });

  final ImagesCacheManager imagesCacheManager;

  final LogBox logBox;

  final ValueSetter<String>? onTapShortcut;

  final AsyncValueGetter<ImageMenu?>? onTapImageMenu;

  static Widget create({
    required ServiceLocator locator,
    required String? source,
    required String? mangaId,
    required String? chapterId,
    ValueSetter<String>? onTapShortcut,
    AsyncValueGetter<ImageMenu?>? onTapImageMenu,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaReaderScreenCubit(
          initialState: MangaReaderScreenState(
            mangaId: mangaId,
            chapterId: chapterId,
            source: source?.let(Sources.fromName),
          ),
          getChapterUseCase: locator(),
          updateChapterUseCase: locator(),
          listenSearchParameterUseCase: locator(),
          recrawlUseCase: locator(),
          prefetchChapterUseCase: locator(),
          getNeighbourChapterUseCase: locator(),
          listenPrefetchChapterConfig: locator(),
        )..init();
      },
      child: MangaReaderScreen(
        imagesCacheManager: locator(),
        onTapShortcut: onTapShortcut,
        onTapImageMenu: onTapImageMenu,
        logBox: locator(),
      ),
    );
  }

  MangaReaderScreenCubit? _cubit(BuildContext context) {
    if (!context.mounted) return null;
    return context.read();
  }

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
      body: Column(
        children: [
          _indicator(context: context),
          Expanded(child: _content(context: context)),
        ],
      ),
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
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              if (error is FailedParsingHtmlException) {
                _onTapRecrawl(context: context, url: error.url);
              } else {
                _cubit(context)?.init();
              }
            },
            child: const Text('Open Debug Browser'),
          ),
        ],
      ),
    );
  }

  Widget _indicator({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.progress != curr.progress,
          prev.isLoading != curr.isLoading,
        ].contains(true);
      },
      builder: (context, state) {
        if (state.isLoading) return const SizedBox.shrink();
        return LinearProgressIndicator(
          value: state.progress,
          color: Colors.grey,
        );
      },
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
          prev.isLoadingNeighbourChapters != curr.isLoadingNeighbourChapters,
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
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    if (url != null) {
                      _onTapRecrawl(context: context, url: url);
                    } else {
                      _cubit(context)?.init();
                    }
                  },
                  child: const Text('Open Debug Browser'),
                ),
              ],
            ),
          );
        }

        return MangaPageView(
          mode: MangaPageViewMode.continuous,
          direction: MangaPageViewDirection.down,
          pageCount: images.length,
          onProgressChange: (e) => _cubit(context)?.set(progress: e),
          options: const MangaPageViewOptions(
            crossAxisOverscroll: false,
            precacheAhead: 1,
            precacheBehind: 1,
            maxZoomLevel: 4,
            minZoomLevel: 1,
            edgeIndicatorContainerSize: 100,
          ),
          pageBuilder: (context, index) {
            return InkWell(
              onLongPress: () {
                _onTapMenu(context: context, url: images.elementAt(index));
              },
              child: CachedNetworkImage(
                imageUrl: images.elementAt(index),
                cacheManager: imagesCacheManager,
                errorWidget: (context, url, error) {
                  return ImageInfoWidget.error(
                    url: url,
                    error: error,
                  );
                },
                progressIndicatorBuilder: (context, url, progress) {
                  return ImageInfoWidget.loading(
                    url: url,
                    progress: progress.progress,
                  );
                },
              ),
            );
          },
          startEdgeDragIndicatorBuilder: (context, info) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isLoadingNeighbourChapters) ...[
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ] else if (prevId != null) ...[
                    const Icon(Icons.arrow_upward),
                    const Text('Previous Chapter'),
                  ] else ...[
                    const Text('No Previous Chapter'),
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
                  if (state.isLoadingNeighbourChapters) ...[
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(),
                    ),
                  ] else if (nextId != null) ...[
                    const Icon(Icons.arrow_downward),
                    const Text('Next Chapter'),
                  ] else ...[
                    const Text('No Next Chapter'),
                  ],
                ],
              ),
            );
          },
          onStartEdgeDrag: () {
            if (state.isLoadingNeighbourChapters || prevId == null) return;
            onTapShortcut?.call(prevId);
          },
          onEndEdgeDrag: () {
            if (state.isLoadingNeighbourChapters || nextId == null) return;
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
    _cubit(context)?.recrawl(context: context, url: url);
  }

  void _onTapMenu({required BuildContext context, required String url}) async {
    final result = await onTapImageMenu?.call();
    if (!context.mounted || result == null) return;
    await _cubit(context)?.removeImage(url: url);
  }
}
