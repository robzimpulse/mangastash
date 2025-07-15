import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_history_screen_cubit.dart';
import 'manga_history_screen_state.dart';

class MangaHistoryScreen extends StatelessWidget {
  const MangaHistoryScreen({
    super.key,
    required this.cacheManager,
    this.onTapManga,
    this.onTapChapter,
  });

  final BaseCacheManager cacheManager;

  final ValueSetter<Manga?>? onTapManga;

  final Function(Manga, Chapter)? onTapChapter;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    Function(Manga, Chapter)? onTapChapter,
  }) {
    return BlocProvider(
      create: (context) => MangaHistoryScreenCubit(
        listenReadHistoryUseCase: locator(),
      )..init(),
      child: MangaHistoryScreen(
        cacheManager: locator(),
        onTapChapter: onTapChapter,
        onTapManga: onTapManga,
      ),
    );
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaHistoryScreenState> builder,
    BlocBuilderCondition<MangaHistoryScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaHistoryScreenCubit, MangaHistoryScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _manga({required BuildContext context, required Manga manga}) {
    return MangaTileWidget(
      padding: const EdgeInsets.all(8),
      manga: manga,
      onTap: () => onTapManga?.call(manga),
      cacheManager: cacheManager,
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
      uploadedAt: chapter.createdAt,
      lastReadAt: chapter.lastReadAt,
      groups: chapter.scanlationGroup,
      onTap: () => onTapChapter?.call(manga, chapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Histories'),
      ),
      body: _builder(
        builder: (context, state) => CustomScrollView(
          slivers: [
            for (final history in state.histories.entries)
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
