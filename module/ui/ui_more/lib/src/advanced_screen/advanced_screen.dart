import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';
import 'advanced_screen_state.dart';

class AdvancedScreen extends StatelessWidget {
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final StorageManager storageManager;
  final HeadlessWebviewUseCase webview;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.storageManager,
    required this.webview,
  });

  static Widget create({required ServiceLocator locator}) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(),
      child: AdvancedScreen(
        logBox: locator(),
        database: locator(),
        viewer: locator(),
        storageManager: locator(),
        webview: locator(),
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
                await Future.wait([storageManager.clear(), database.clear()]);
                if (!context.mounted) return;
                context.showSnackBar(message: 'Success Clear Database & Cache');
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ),
          FutureBuilder(
            future: Future.delayed(
              const Duration(seconds: 1),
              () => webview.open(
                'https://www.scrapingcourse.com/cloudflare-challenge',
                useCache: false,
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final data = snapshot.data;
                final error = snapshot.error;

                final children = <Widget>[
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Text(error.toString()),
                    ),
                  if (data != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Text(data.outerHtml),
                    ),
                ].intersperse(const SizedBox(height: 16));

                return ExpansionTile(
                  title: const Text('Headless Browser - Cloudflare Challenge'),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.web),
                  ),
                  children: children.toList(),
                );
              }

              return const ListTile(
                title: Text('Headless Browser - Cloudflare Challenge'),
                leading: SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.web),
                ),
                trailing: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
