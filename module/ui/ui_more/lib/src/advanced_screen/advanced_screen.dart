import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';
import 'advanced_screen_state.dart';

class AdvancedScreen extends StatelessWidget {
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final HeadlessWebviewUseCase webview;
  final ImagesCacheManager imagesCacheManager;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.webview,
    required this.imagesCacheManager,
  });

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (_) {
        return AdvancedScreenCubit(
          diagnosticDao: locator(),
          mangaDao: locator(),
          chapterDao: locator(),
        );
      },
      child: AdvancedScreen(
        logBox: locator(),
        database: locator(),
        viewer: locator(),
        webview: locator(),
        imagesCacheManager: locator(),
      ),
    );
  }

  Widget _buildLogInspector(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        title: const Text('Log Inspector'),
        onTap: () => logBox.dashboard(context: context),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.wrap_text),
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildDatabaseInspector(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListTile(
        title: const Text('Database Inspector'),
        onTap: () => viewer.navigateToViewer(database: database),
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(Icons.storage),
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildBrowserTester(BuildContext context) {
    return SliverToBoxAdapter(
      child: ExpansionTile(
        title: const Text('Browser Tester'),
        subtitle: const Text('Cloudflare Challenge Tester and Browser'),
        leading: Icon(Icons.web),
        children: [
          ListTile(
            title: TextField(
              decoration: InputDecoration(
                hintText: 'eg: https://www.google.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) async {
                final uri = Uri.tryParse(text);
                if (uri == null) return;
                await logBox.webview(context: context, uri: uri);
              },
            ),
            leading: Icon(Icons.web_asset),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('Cloudflare Challenge'),
            leading: Icon(Icons.cloud_circle),
            onTap: () async {
              final uri = Uri.tryParse(
                'https://www.scrapingcourse.com/cloudflare-challenge',
              );
              if (uri == null) return;
              await logBox.webview(context: context, uri: uri);
            },
          ),
        ],
      ),
    );
  }

  Widget _builder({
    required BlocWidgetBuilder<AdvancedScreenState> builder,
    BlocBuilderCondition<AdvancedScreenState>? buildWhen,
  }) {
    return BlocBuilder<AdvancedScreenCubit, AdvancedScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  AdvancedScreenCubit _cubit(BuildContext context) => context.read();

  Widget _buildDuplicateMangaDetector(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.duplicatedManga != curr.duplicatedManga,
          prev.isDuplicatedMangaExpanded != curr.isDuplicatedMangaExpanded,
        ].contains(true);
      },
      builder: (context, state) {
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListTile(
                  title: Text(
                    'Duplicated Manga (${state.duplicatedManga.length})',
                  ),
                  subtitle: const Text('List based on title and source'),
                  trailing: Icon(
                    state.isDuplicatedMangaExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    _cubit(
                      context,
                    ).showDuplicateManga(!state.isDuplicatedMangaExpanded);
                  },
                ),
              ),
            ),

            if (state.isDuplicatedMangaExpanded)
              if (state.duplicatedManga.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Record',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else ...[
                for (final value in state.duplicatedManga.entries)
                  SliverPadding(
                    padding: EdgeInsets.only(left: 16),
                    sliver: MultiSliver(
                      pushPinnedChildren: true,
                      children: [
                        SliverPinnedHeader(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ListTile(
                              title: Text('Title: ${value.key.$1}'),
                              subtitle: Text('Source: ${value.key.$2}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('(${value.value.length})'),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      _deleteDuplicateMangas(
                                        context: context,
                                        mangas: value.value,
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList.separated(
                          itemCount: value.value.length,
                          itemBuilder: (context, index) {
                            final data = value.value.elementAtOrNull(index);
                            if (data == null) return null;

                            return MangaTileWidget.manga(
                              padding: EdgeInsets.only(left: 16, right: 32),
                              manga: Manga.fromDrift(data),
                              cacheManager: imagesCacheManager,
                            );
                          },
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 8);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        );
      },
    );
  }

  Widget _buildDuplicateChapterDetector(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.duplicatedChapter != curr.duplicatedChapter,
          prev.isDuplicatedChapterExpanded != curr.isDuplicatedChapterExpanded,
        ].contains(true);
      },
      builder: (context, state) {
        return MultiSliver(
          children: [
            SliverPinnedHeader(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListTile(
                  title: Text(
                    'Duplicated Chapter (${state.duplicatedChapter.length})',
                  ),
                  subtitle: const Text(
                    'List based on manga id and chapter name',
                  ),
                  trailing: Icon(
                    state.isDuplicatedChapterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    _cubit(
                      context,
                    ).showDuplicateChapter(!state.isDuplicatedChapterExpanded);
                  },
                ),
              ),
            ),

            if (state.isDuplicatedChapterExpanded)
              if (state.duplicatedChapter.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Record',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else ...[
                for (final value in state.duplicatedChapter.entries)
                  SliverPadding(
                    padding: EdgeInsets.only(left: 16),
                    sliver: MultiSliver(
                      pushPinnedChildren: true,
                      children: [
                        SliverPinnedHeader(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ListTile(
                              title: Text('Manga ID: ${value.key.$1}'),
                              subtitle: Text('Chapter: ${value.key.$2}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('(${value.value.length})'),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      _deleteDuplicateChapters(
                                        context: context,
                                        chapters: value.value,
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList.separated(
                          itemCount: value.value.length,
                          itemBuilder: (context, index) {
                            final data = value.value.elementAtOrNull(index);
                            if (data == null) return null;

                            return ChapterTileWidget.chapter(
                              chapter: Chapter.fromDrift(data),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            );
                          },
                          separatorBuilder: (_, __) {
                            return const SizedBox(height: 8);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        );
      },
    );
  }

  Widget _buildDuplicateTagDetector(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.duplicatedTag != curr.duplicatedTag,
          prev.isDuplicatedTagExpanded != curr.isDuplicatedTagExpanded,
        ].contains(true);
      },
      builder: (context, state) {
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListTile(
                  title: Text(
                    'Duplicated Tag Record (${state.duplicatedTag.length})',
                  ),
                  subtitle: const Text('List based on name and source'),
                  trailing: Icon(
                    state.isDuplicatedTagExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    _cubit(
                      context,
                    ).showDuplicateTag(!state.isDuplicatedTagExpanded);
                  },
                ),
              ),
            ),

            if (state.isDuplicatedTagExpanded)
              if (state.duplicatedTag.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Record',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else ...[
                for (final value in state.duplicatedTag.entries)
                  SliverPadding(
                    padding: EdgeInsets.only(left: 16),
                    sliver: MultiSliver(
                      pushPinnedChildren: true,
                      children: [
                        SliverPinnedHeader(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ListTile(
                              title: Text('Name: ${value.key.$1}'),
                              subtitle: Text('Source: ${value.key.$2}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('(${value.value.length})'),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      _deleteDuplicateTags(
                                        context: context,
                                        tags: value.value,
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        for (final child in value.value)
                          SliverToBoxAdapter(
                            child: ListTile(
                              title: Text(child.tagId ?? ''),
                              subtitle: Text(
                                'Updated At: ${child.updatedAt.readableFormat}',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
          ],
        );
      },
    );
  }

  Widget _buildOrphanChapterDetector(BuildContext context) {
    return _builder(
      buildWhen: (prev, curr) {
        return [
          prev.orphanedChapter != curr.orphanedChapter,
          prev.isOrphanedExpanded != curr.isOrphanedExpanded,
        ].contains(true);
      },
      builder: (context, state) {
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ListTile(
                  title: Text(
                    'Orphan Chapter Record (${state.orphanedChapter.length})',
                  ),
                  subtitle: const Text(
                    'List based on chapter that have no manga',
                  ),
                  trailing: Icon(
                    state.isOrphanedExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onTap: () {
                    _cubit(
                      context,
                    ).showOrphanedChapter(!state.isOrphanedExpanded);
                  },
                ),
              ),
            ),

            if (state.isOrphanedExpanded)
              if (state.orphanedChapter.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Record',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: state.orphanedChapter.length,
                  itemBuilder: (context, index) {
                    final data = state.orphanedChapter.elementAtOrNull(index);
                    if (data == null) return null;

                    return ChapterTileWidget.chapter(
                      chapter: Chapter.fromDrift(data),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 8);
                  },
                ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: const Text('Advanced Screen')),
      body: CustomScrollView(
        slivers: [
          _buildLogInspector(context),
          _buildDatabaseInspector(context),
          _buildBrowserTester(context),
          _buildDuplicateMangaDetector(context),
          _buildDuplicateChapterDetector(context),
          _buildDuplicateTagDetector(context),
          _buildOrphanChapterDetector(context),
        ],
      ),
    );
  }

  void _deleteDuplicateMangas({
    required BuildContext context,
    required List<MangaDrift> mangas,
  }) {
    context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _deleteDuplicateChapters({
    required BuildContext context,
    required List<ChapterDrift> chapters,
  }) {
    context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }

  void _deleteDuplicateTags({
    required BuildContext context,
    required List<TagDrift> tags,
  }) {
    context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
  }
}
