import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_reader_screen_cubit.dart';
import 'manga_reader_screen_state.dart';

class MangaReaderScreen extends StatelessWidget {
  const MangaReaderScreen({
    super.key,
    required this.cacheManager,
    this.onTapShortcut,
  });

  final BaseCacheManager cacheManager;

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
          sourceEnum: source,
          chapterIds: chapterIds,
        ),
        getChapterUseCase: locator(),
        getMangaSourceUseCase: locator(),
        crawlUrlUseCase: locator(),
      )..init(),
      child: MangaReaderScreen(
        cacheManager: locator(),
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
      body: _builder(
        buildWhen: (prev, curr) => [
          prev.isLoading != curr.isLoading,
          prev.error != curr.error,
        ].contains(true),
        builder: (context, state) {
          final error = state.error;
          if (error != null) {
            return _errorContent(context: context, error: error);
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _content();
        },
      ),
    );
  }

  Widget _errorContent({
    required BuildContext context,
    required Exception error,
  }) {
    return Center(
      child: Column(
        children: [
          Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
          if (error is FailedParsingHtmlException) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _cubit(context).recrawl(url: error.url),
              child: const Text('Open Debug Browser'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _content() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.chapter?.images != curr.chapter?.images,
        prev.chapter?.webUrl != curr.chapter?.webUrl,
      ].contains(true),
      builder: (context, state) => Column(
        children: [
          Row(children: [Expanded(child: _prevButton())]),
          Expanded(
            child: _images(
              context: context,
              images: state.chapter?.images ?? [],
              sourceUrl: state.chapter?.webUrl,
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
      ].contains(true),
      builder: (context, state) => state.previousChapterId != null
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onTapShortcut?.call(state.previousChapterId),
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
              onPressed: () => onTapShortcut?.call(state.nextChapterId),
              child: const Text('Next Chapter'),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _images({
    required BuildContext context,
    required List<String> images,
    String? sourceUrl,
  }) {
    final url = sourceUrl;
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Images Empty'),
            if (url != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _cubit(context).recrawl(url: url),
                child: const Text('Open Debug Browser'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) => CachedNetworkImage(
        cacheManager: cacheManager,
        imageUrl: images[index],
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
      itemCount: images.length,
    );
  }
}
