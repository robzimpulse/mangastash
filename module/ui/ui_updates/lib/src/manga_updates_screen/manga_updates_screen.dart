import 'package:core_environment/core_environment.dart';
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

  Widget _manga({
    required BuildContext context,
    required Manga manga,
    bool isPrefetching = false,
  }) {
    return MangaTileWidget(
      padding: const EdgeInsets.all(8),
      manga: manga,
      onTap: () => onTapManga?.call(manga),
      cacheManager: imagesCacheManager,
      isPrefetching: isPrefetching,
    );
  }

  Widget _chapter({
    required BuildContext context,
    required Manga manga,
    required Chapter chapter,
    bool isPrefetching = false,
  }) {
    return ChapterTileWidget(
      padding: const EdgeInsets.all(8),
      title: ['Chapter ${chapter.chapter}', chapter.title].nonNulls.join(' - '),
      language: Language.fromCode(chapter.translatedLanguage),
      uploadedAt: chapter.readableAt,
      groups: chapter.scanlationGroup,
      isPrefetching: isPrefetching,
      onTap: () => onTapChapter?.call(manga, chapter),
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
          return CustomScrollView(
            slivers: [
              if (state.updates.values.every((e) => e.isEmpty))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
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
                    ),
                  ),
                )
              else
                for (final history in state.updates.entries)
                  if (history.value.isNotEmpty)
                    MultiSliver(
                      pushPinnedChildren: true,
                      children: [
                        SliverPinnedHeader(
                          child: _manga(
                            context: context,
                            manga: history.key,
                            isPrefetching: state.prefetchedMangaIds.contains(
                              history.key.id,
                            ),
                          ),
                        ),
                        SliverList.builder(
                          itemBuilder: (context, index) {
                            final item = history.value.elementAtOrNull(index);
                            if (item == null) return null;
                            final ids = state.prefetchedChapterIds;
                            return _chapter(
                              context: context,
                              manga: history.key,
                              chapter: item,
                              isPrefetching: ids.contains(item.id),
                            );
                          },
                          itemCount: history.value.length,
                        ),
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }
}
