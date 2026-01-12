import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';

class AdvancedScreen extends StatelessWidget {
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final HeadlessWebviewUseCase webview;
  final DiagnosticDao diagnosticDao;
  final ImagesCacheManager imagesCacheManager;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.webview,
    required this.diagnosticDao,
    required this.imagesCacheManager,
  });

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(),
      child: AdvancedScreen(
        logBox: locator(),
        database: locator(),
        viewer: locator(),
        webview: locator(),
        diagnosticDao: locator(),
        imagesCacheManager: locator(),
      ),
    );
  }

  Widget _buildLogInspector(BuildContext context) {
    return ListTile(
      title: const Text('Log Inspector'),
      onTap: () => logBox.dashboard(context: context),
      leading: const SizedBox(
        height: double.infinity,
        child: Icon(Icons.wrap_text),
      ),
    );
  }

  Widget _buildDatabaseInspector(BuildContext context) {
    return ListTile(
      title: const Text('Database Inspector'),
      onTap: () => viewer.navigateToViewer(database: database),
      leading: const SizedBox(
        height: double.infinity,
        child: Icon(Icons.storage),
      ),
      trailing: IconButton(
        onPressed: () async {
          await database.clear();
          if (!context.mounted) return;
          context.showSnackBar(message: 'Success Clear Database & Cache');
        },
        icon: const Icon(Icons.delete_forever),
      ),
    );
  }

  Widget _buildBrowserTester(BuildContext context) {
    return ExpansionTile(
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
    );
  }

  Widget _buildDuplicateMangaDetector(BuildContext context) {
    return StreamBuilder(
      stream: diagnosticDao.duplicateManga,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Duplicated Manga Record'),
          subtitle: const Text('List based on title and source'),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting) ...[
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              if (data != null) ...[
                if (data.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Duplicate Detected',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  for (final value in data.entries)
                    ExpansionTile(
                      title: Text('Title: ${value.key.$1}'),
                      subtitle: Text('Source: ${value.key.$2}'),
                      children: [
                        for (final child in value.value)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: MangaTileWidget(
                              manga: Manga.fromDrift(child),
                              cacheManager: imagesCacheManager,
                            ),
                          ),
                      ],
                    ),
                ],
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildDuplicateChapterDetector(BuildContext context) {
    return StreamBuilder(
      stream: diagnosticDao.duplicateChapter,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Duplicated Chapter Record'),
          subtitle: const Text('List based on manga id and chapter name'),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting) ...[
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              if (data != null) ...[
                if (data.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Duplicate Detected',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  for (final value in data.entries)
                    ExpansionTile(
                      title: Text('Manga ID: ${value.key.$1}'),
                      subtitle: Text('Chapter: ${value.key.$2}'),
                      children: [
                        for (final child in value.value)
                          ListTile(
                            title: Text(child.id),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.webUrl ?? ''),
                                Text(
                                  'Updated At: ${child.updatedAt.readableFormat}',
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildDuplicateTagDetector(BuildContext context) {
    return StreamBuilder(
      stream: diagnosticDao.duplicateTag,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Duplicated Tag Record'),
          subtitle: const Text('List based on name and source'),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting) ...[
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              if (data != null) ...[
                if (data.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Duplicate Detected',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  for (final value in data.entries)
                    ExpansionTile(
                      title: Text('Name: ${value.key.$1}'),
                      subtitle: Text('Source: ${value.key.$2}'),
                      children: [
                        for (final child in value.value)
                          ListTile(
                            title: Text(child.tagId ?? ''),
                            subtitle: Text(
                              'Updated At: ${child.updatedAt.readableFormat}',
                            ),
                          ),
                      ],
                    ),
                ],
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildOrphanChapterDetector(BuildContext context) {
    return StreamBuilder(
      stream: diagnosticDao.orphanChapter,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Orphan Chapter Record'),
          subtitle: const Text('List based on chapter that have no manga'),
          children: [
            if (snapshot.connectionState == ConnectionState.waiting) ...[
              const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              if (data != null) ...[
                if (data.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No Orphan Chapter Detected',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  for (final value in data)
                    ChapterTileWidget(
                      title: [
                        'Chapter ${value.chapter}',
                        value.title,
                      ].nonNulls.join(' - '),
                      language: Language.fromCode(value.translatedLanguage),
                      uploadedAt: value.readableAt,
                      groups: value.scanlationGroup,
                      lastReadAt: value.lastReadAt,
                    ),
                ],
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: const Text('Advanced Screen')),
      body: AdaptivePhysicListView(
        children: [
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
}
