import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class AdvancedScreen extends StatelessWidget {
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final HeadlessWebviewUseCase webview;

  const AdvancedScreen({
    super.key,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.webview,
  });

  static Widget create({required ServiceLocator locator}) {
    return AdvancedScreen(
      logBox: locator(),
      database: locator(),
      viewer: locator(),
      webview: locator(),
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
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('Database Inspector'),
            onTap: () => viewer.navigateToViewer(database: database),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.storage),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: const Text('Database Diagnostic'),
            onTap: () => database.diagnostic(context: context),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.healing),
            ),
            trailing: Icon(Icons.chevron_right),
          ),
          ExpansionTile(
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
        ],
      ),
    );
  }
}
