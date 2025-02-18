import 'package:collection/collection.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'manga_reader_screen_cubit.dart';
import 'manga_reader_screen_state.dart';

class MangaReaderScreen extends StatelessWidget {
  const MangaReaderScreen({
    super.key,
    required this.cacheManager,
    required this.logBox,
    this.onTapShortcut,
  });

  final BaseCacheManager cacheManager;

  final LogBox logBox;

  final void Function(String?)? onTapShortcut;

  static Widget create({
    required ServiceLocator locator,
    required MangaSourceEnum? source,
    required String? mangaId,
    required String? chapterId,
    List<String>? chapterIds,
    void Function(String?)? onTapShortcut,
  }) {
    return BlocProvider(
      create: (context) => MangaReaderScreenCubit(
        initialState: MangaReaderScreenState(
          mangaId: mangaId,
          chapterId: chapterId,
          source: source,
          chapterIds: chapterIds,
        ),
        getChapterUseCase: locator(),
        cacheManager: locator(),
        getMangaSourceUseCase: locator(),
      )..init(),
      child: MangaReaderScreen(
        cacheManager: locator(),
        logBox: locator(),
        onTapShortcut: onTapShortcut,
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
      body: SafeArea(
        child: _builder(
          buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
          builder: (context, state) => state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [_content(), _indicator()],
                ),
        ),
      ),
    );
  }

  Widget _indicator() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.progress != curr.progress,
        prev.chapter?.images != curr.chapter?.images,
      ].any((e) => e),
      builder: (context, state) => Positioned(
        bottom: double.minPositive,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
            ),
            child: Text(
              'Page ${state.progress} of ${state.chapter?.images?.length}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return _builder(
      buildWhen: (prev, curr) => prev.chapter?.images != curr.chapter?.images,
      builder: (context, state) => Column(
        children: [
          Row(children: [Expanded(child: _prevButton())]),
          Expanded(
            child: CustomScrollView(
              slivers: _images(
                context: context,
                images: state.chapter?.images ?? [],
              ),
            ),
          ),
          Row(children: [Expanded(child: _nextButton())]),
        ],
      ),
    );
  }

  Widget _prevButton() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.previousChapterId != curr.previousChapterId,
      ].any((e) => e),
      builder: (context, state) => state.previousChapterId != null
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onTapShortcut?.call(
                state.previousChapterId,
              ),
              child: const Text('Previous Chapter'),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _nextButton() {
    return _builder(
      buildWhen: (prev, curr) => prev.nextChapterId != curr.nextChapterId,
      builder: (context, state) => state.nextChapterId != null
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onTapShortcut?.call(
                state.nextChapterId,
              ),
              child: const Text('Next Chapter'),
            )
          : const SizedBox.shrink(),
    );
  }

  List<Widget> _images({
    required BuildContext context,
    required List<String> images,
  }) {
    if (images.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Images Empty'),
                const SizedBox(height: 16),
                _builder(
                  buildWhen: (prev, curr) => [
                    prev.rawHtml != curr.rawHtml,
                    prev.chapter?.webUrl != curr.chapter?.webUrl,
                  ].any((e) => e),
                  builder: (context, state) {
                    final html = state.rawHtml;
                    final uri = Uri.tryParse(state.chapter?.webUrl ?? '');

                    if (html == null || uri == null) {
                      return const SizedBox.shrink();
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => logBox.navigateToWebview(
                        uri: uri,
                        html: html,
                        onTapSnapshot: (value) => _cubit(context).init(
                          uri: uri,
                          html: value,
                        ),
                      ),
                      child: const Text('Open Debug Browser'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return List.from(
      images.mapIndexed(
        (index, image) => SliverToBoxAdapter(
          child: VisibilityDetector(
            key: ValueKey<int>(index),
            onVisibilityChanged: (info) {
              if (!context.mounted) return;
              _cubit(context).onVisibility(
                key: '$index',
                visibleFraction: info.visibleFraction,
              );
            },
            child: CachedNetworkImage(
              cacheManager: cacheManager,
              imageUrl: image,
              errorWidget: (context, url, error) => ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(Icons.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error.toString())),
                    ],
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, progress) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
