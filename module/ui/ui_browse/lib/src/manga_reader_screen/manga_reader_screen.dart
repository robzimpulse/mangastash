import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/services.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'manga_reader_screen_cubit.dart';
import 'manga_reader_screen_state.dart';

class MangaReaderScreen extends StatefulWidget {
  const MangaReaderScreen({
    super.key,
    this.cacheManager,
    this.onTapShortcut,
  });

  final BaseCacheManager? cacheManager;

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
        getMangaSourceUseCase: locator(),
      )..init(),
      child: MangaReaderScreen(
        cacheManager: locator(),
        onTapShortcut: onTapShortcut,
      ),
    );
  }

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  MangaReaderScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<MangaReaderScreenState> builder,
    BlocBuilderCondition<MangaReaderScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaReaderScreenCubit, MangaReaderScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      bottomSafeArea: false,
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return prev.isLoading != curr.isLoading ||
            prev.chapter?.images != curr.chapter?.images;
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final images = state.chapter?.images ?? [];

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _builder(
                    buildWhen: (prev, curr) => [
                      prev.previousChapterId != curr.previousChapterId,
                    ].any((e) => e),
                    builder: (context, state) => state.previousChapterId != null
                        ? ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () => widget.onTapShortcut?.call(
                              state.previousChapterId,
                            ),
                            child: const Text('Previous Chapter'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: images.length,
                    (context, index) => VisibilityDetector(
                      onVisibilityChanged: (info) {
                        if (!context.mounted) return;
                        _cubit(context).onVisibility(
                          key: images[index],
                          visibleFraction: info.visibleFraction,
                        );
                      },
                      key: ValueKey<int>(index),
                      child: CachedNetworkImage(
                        cacheManager: widget.cacheManager,
                        imageUrl: images[index],
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
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
                SliverToBoxAdapter(
                  child: _builder(
                    buildWhen: (prev, curr) => [
                      prev.nextChapterId != curr.nextChapterId,
                    ].any((e) => e),
                    builder: (context, state) => state.nextChapterId != null
                        ? ElevatedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            onPressed: () => widget.onTapShortcut?.call(
                              state.nextChapterId,
                            ),
                            child: const Text('Next Chapter'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            _builder(
              buildWhen: (prev, curr) => prev.progress != curr.progress,
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
                      'Page ${state.progress} of ${images.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
