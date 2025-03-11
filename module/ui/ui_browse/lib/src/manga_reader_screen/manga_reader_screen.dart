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
      appBar: AppBar(
        title: _title(),
        actions: [_recrawlButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: _content(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _prevButton(),
              _nextButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.chapter?.chapter != curr.chapter?.chapter,
        prev.isLoading != curr.isLoading,
      ].contains(true),
      builder: (context, state) => ShimmerLoading.multiline(
        isLoading: state.isLoading,
        width: 100,
        height: 20,
        lines: 1,
        child: Text('Chapter ${state.chapter?.chapter}'),
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
            OutlinedButton(
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
        prev.isLoading != curr.isLoading,
        prev.error != curr.error,
        prev.chapter?.images != curr.chapter?.images,
      ].contains(true),
      builder: (context, state) {
        final error = state.error;
        final images = state.chapter?.images ?? [];

        if (error != null) {
          return _errorContent(context: context, error: error);
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (images.isEmpty) {
          return const Center(child: Text('Images Empty'));
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
      },
    );
  }

  Widget _prevButton() {
    return _builder(
      buildWhen: (prev, curr) => [
        prev.previousChapterId != curr.previousChapterId,
      ].contains(true),
      builder: (context, state) {
        if (state.previousChapterId == null) {
          return const SizedBox.shrink();
        }
        return IconButton(
          onPressed: () => onTapShortcut?.call(state.previousChapterId),
          icon: const Icon(Icons.navigate_before),
        );
      },
    );
  }

  Widget _nextButton() {
    return _builder(
      buildWhen: (prev, curr) => prev.nextChapterId != curr.nextChapterId,
      builder: (context, state) {
        if (state.nextChapterId == null) {
          return const SizedBox.shrink();
        }
        return IconButton(
          onPressed: () => onTapShortcut?.call(state.nextChapterId),
          icon: const Icon(Icons.navigate_next),
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
          onPressed: () => _cubit(context).recrawl(url: url),
          icon: const Icon(Icons.web),
        );
      },
    );
  }
}
