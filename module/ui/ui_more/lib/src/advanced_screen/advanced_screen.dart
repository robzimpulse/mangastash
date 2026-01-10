import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';

class AdvancedScreen extends StatelessWidget {
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final ImagesCacheManager imagesCacheManager;
  final HeadlessWebviewUseCase webview;
  final DiagnosticDao diagnosticDao;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.imagesCacheManager,
    required this.webview,
    required this.diagnosticDao,
  });

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(),
      child: AdvancedScreen(
        logBox: locator(),
        database: locator(),
        viewer: locator(),
        imagesCacheManager: locator(),
        webview: locator(),
        diagnosticDao: locator(),
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
    return FutureBuilder(
      future: diagnosticDao.duplicatedManga,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Duplicated Manga Record'),
          subtitle: const Text('List based on title and source'),
          children: [
            if (snapshot.connectionState != ConnectionState.done) ...[
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
                  for (final value in data)
                    ExpansionTile(
                      title: Text('Title: ${value.duplicatedManga?.key.$2}'),
                      subtitle: Text(
                        'Source: ${value.duplicatedManga?.key.$1}',
                      ),
                      children: [
                        for (final child in value.duplicatedManga?.value ?? <MangaModel>[])
                          ListTile(
                            title: Text(child.manga?.id ?? ''),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(child.manga?.webUrl ?? ''),
                                Text(
                                  'Updated At: ${child.manga?.updatedAt.readableFormat}',
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

  Widget _buildMissingMangaTagRelationshipDetector(BuildContext context) {
    return FutureBuilder(
      future: diagnosticDao.missingMangaTagRelationship,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ExpansionTile(
          title: const Text('Missing Manga <-> Tag Relationship'),
          subtitle: Text('${data?.length} Record Found'),
          children: [
            if (snapshot.connectionState != ConnectionState.done) ...[
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
                      'No Missing Manga <-> Tag Detected',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ] else ...[
                  for (final value in data)
                    ListTile(
                      title: Text(
                        'Manga ID: ${value.manga?.title} - ${value.manga?.source}',
                      ),
                      subtitle: Text(
                        'Tag Name: ${value.tag?.name} - ${value.tag?.source}',
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          final manga = value.manga;
                          final tag = value.tag;

                          if (manga == null) {
                            context.showSnackBar(
                              message: '${tag?.id} missing link to manga',
                            );
                            return;
                          }

                          if (tag == null) {
                            context.showSnackBar(
                              message: '${manga.id} missing link to tag',
                            );
                            return;
                          }
                        },
                        icon: Icon(Icons.delete),
                      ),
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
          _buildMissingMangaTagRelationshipDetector(context),
        ],
      ),
    );
  }
}
