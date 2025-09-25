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
          ListTile(
            title: const Text('Cloudflare Challenge'),
            subtitle: const Text(
              'List of Browser Cookies after opening cloudflare challenge',
            ),
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
              final manager = CookieManager.instance();
              final cookies = await manager.getAllCookies();
              if (!context.mounted) return;
              context.showSnackBar(
                message: 'Cookies Key: ${cookies.map((e) => e.name)}',
              );
            },
          ),
        ],
      ),
    );
  }
}
