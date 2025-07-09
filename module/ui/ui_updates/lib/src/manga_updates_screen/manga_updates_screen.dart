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
    required this.cacheManager,
    this.onTapManga,
    this.onTapChapter,
  });

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    Function(Manga, Chapter)? onTapChapter,
  }) {
    return BlocProvider(
      create: (context) => MangaUpdatesScreenCubit(
        listenUnreadHistoryUseCase: locator(),
        listenMangaFromLibraryUseCase: locator(),
      )..init(),
      child: MangaUpdatesScreen(
        cacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapManga: onTapManga,
      ),
    );
  }

  final BaseCacheManager cacheManager;

  final ValueSetter<Manga?>? onTapManga;

  final Function(Manga, Chapter)? onTapChapter;

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaUpdatesScreenState> builder,
    BlocBuilderCondition<MangaUpdatesScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaUpdatesScreenCubit, MangaUpdatesScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _manga({required BuildContext context, required Manga manga}) {
    return MangaShelfItem(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: manga.title ?? '',
      coverUrl: manga.coverUrl ?? '',
      sourceIconUrl: manga.source?.let(
        (e) => SourceEnum.fromValue(name: e)?.icon,
      ),
      layout: MangaShelfItemLayout.list,
      cacheManager: cacheManager,
      onTap: () => onTapManga?.call(manga),
    );
  }

  Widget _chapter({
    required BuildContext context,
    required Manga manga,
    required Chapter chapter,
  }) {
    return ChapterTileWidget(
      padding: const EdgeInsets.all(8),
      title: ['Chapter ${chapter.chapter}', chapter.title].nonNulls.join(' - '),
      language: Language.fromCode(chapter.translatedLanguage),
      uploadedAt: chapter.readableAt,
      groups: chapter.scanlationGroup,
      onTap: () => onTapChapter?.call(manga, chapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Manga Updates'),
      ),
      body: _builder(
        builder: (context, state) => CustomScrollView(
          slivers: [
            for (final history in state.updates.entries)
              if (history.value.isNotEmpty)
                MultiSliver(
                  pushPinnedChildren: true,
                  children: [
                    SliverPinnedHeader(
                      child: _manga(context: context, manga: history.key),
                    ),
                    for (final item in history.value)
                      SliverToBoxAdapter(
                        child: _chapter(
                          context: context,
                          manga: history.key,
                          chapter: item,
                        ),
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
