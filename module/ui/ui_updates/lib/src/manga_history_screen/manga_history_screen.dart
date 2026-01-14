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
    required this.imagesCacheManager,
    this.onTapManga,
    this.onTapChapter,
  });

  final ImagesCacheManager imagesCacheManager;

  final ValueSetter<Manga?>? onTapManga;

  final Function(Manga, Chapter)? onTapChapter;

  static Widget create({
    required ServiceLocator locator,
    ValueSetter<Manga?>? onTapManga,
    Function(Manga, Chapter)? onTapChapter,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaHistoryScreenCubit(listenReadHistoryUseCase: locator());
      },
      child: MangaHistoryScreen(
        imagesCacheManager: locator(),
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(centerTitle: false, title: const Text('Histories')),
      body: _builder(
        builder: (context, state) {
          if (state.histories.isEmpty) {
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
            itemCount: state.histories.length,
            itemBuilder: (context, index) {
              final value = state.histories.elementAtOrNull(index);
              final chapter = value?.chapter;
              final manga = value?.manga;
              if (chapter == null || manga == null) return null;
              return ChapterTileWidget.chapter(
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
