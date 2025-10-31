import 'package:collection/collection.dart';
import 'package:core_analytics/core_analytics.dart';
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
  final ImageCacheManager imagesCacheManager;
  final HeadlessWebviewUseCase webview;
  final MangaDao mangaDao;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.imagesCacheManager,
    required this.webview,
    required this.mangaDao,
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
        mangaDao: locator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: const Text('Advanced Screen')),
      body: AdaptivePhysicListView(
        children: [
          ListTile(
            title: const Text('Log Inspector'),
            onTap: () => logBox.dashboard(context: context),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.wrap_text),
            ),
          ),
          ListTile(
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
          ),
          ListTile(
            title: const Text('Browser - Cloudflare Challenge'),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.web),
            ),
            onTap: () async {
              final uri = Uri.tryParse(
                'https://www.scrapingcourse.com/cloudflare-challenge',
              );
              if (uri == null) return;
              await logBox.webview(context: context, uri: uri);
            },
          ),
          FutureBuilder(
            future: mangaDao.all.then((e) {
              final entries = e
                  .groupListsBy((e) => '${e.manga?.source} | ${e.manga?.title}')
                  .entries
                  .where((e) => e.value.length > 1);

              return Map.fromEntries(entries);
            }),
            builder: (context, snapshot) {
              final data = snapshot.data;

              return ExpansionTile(
                title: const Text('Duplicated Manga Record'),
                subtitle: const Text(
                  'List of Duplicated Manga based on title and source',
                ),
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
                        for (final value in data.entries)
                          ListTile(
                            title: Text(value.key),
                            subtitle: Text('${value.value.length}'),
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
          ),
        ],
      ),
    );
  }
}
