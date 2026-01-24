import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_updates_screen_cubit.dart';
import 'manga_updates_screen_state.dart';

class MangaUpdatesScreen extends StatelessWidget {
  const MangaUpdatesScreen({
    super.key,
    required this.imagesCacheManager,
    this.onTapManga,
    this.onTapChapter,
  });

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    Function(Manga, Chapter)? onTapChapter,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaUpdatesScreenCubit(
          listenUnreadHistoryUseCase: locator(),
          listenMangaFromLibraryUseCase: locator(),
          listenPrefetchUseCase: locator(),
          prefetchChapterUseCase: locator(),
        );
      },
      child: MangaUpdatesScreen(
        imagesCacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapManga: onTapManga,
      ),
    );
  }

  final ImagesCacheManager imagesCacheManager;

  final ValueSetter<Manga?>? onTapManga;

  final Function(Manga, Chapter)? onTapChapter;

  MangaUpdatesScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaUpdatesScreenState> builder,
    BlocBuilderCondition<MangaUpdatesScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaUpdatesScreenCubit, MangaUpdatesScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _layoutRefresh({required BuildContext context}) {
    return _builder(
      buildWhen: (prev, curr) => prev.updates != curr.updates,
      builder: (context, state) {
        if (state.updates.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: const Icon(Icons.cloud_download),
          onPressed: () => _cubit(context).prefetch(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Manga Updates'),
        actions: [_layoutRefresh(context: context)],
      ),
      body: _builder(
        builder: (context, state) {
          if (state.updates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    EmojiAsciiEnum.crying.ascii,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(
                    'Empty Data',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: state.updates.length,
            itemBuilder: (context, index) {
              final value = state.updates.elementAtOrNull(index);
              final chapter = value?.chapter;
              final manga = value?.manga;
              if (chapter == null || manga == null) return null;
              return ChapterTileWidget.chapter(
                padding: EdgeInsets.all(8),
                manga: manga,
                chapter: chapter,
                lastReadAt: chapter.lastReadAt,
                cacheManager: imagesCacheManager,
                onTap: () => onTapChapter?.call(manga, chapter),
              );
            },
            separatorBuilder: (context, _) => SizedBox(height: 8),
          );
        },
      ),
    );
  }
}
