import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:dio_inspector/dio_inspector.dart';
import 'package:log_box/log_box.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';

class AdvancedScreen extends StatelessWidget {
  final DioInspector inspector;
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;
  final BaseCacheManager cacheManager;

  const AdvancedScreen({
    super.key,
    required this.inspector,
    required this.logBox,
    required this.viewer,
    required this.database,
    required this.cacheManager,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(),
      child: AdvancedScreen(
        inspector: locator(),
        logBox: locator(),
        database: locator(),
        viewer: locator(),
        cacheManager: locator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Advanced Screen'),
      ),
      body: AdaptivePhysicListView(
        children: [
          ListTile(
            title: const Text('HTTP Inspector'),
            onTap: () => inspector.navigateToInspector(
              theme: Theme.of(context),
            ),
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(Icons.http),
            ),
          ),
          ListTile(
            title: const Text('Log Inspector'),
            onTap: () => logBox.navigateToLogBox(
              onTapSnapshot: (url, html) {
                if (url == null || html == null) return;
                cacheManager.putFile(
                  url,
                  utf8.encode(html),
                  fileExtension: 'html',
                  maxAge: const Duration(minutes: 30),
                );
              },
            ),
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
                await cacheManager.emptyCache();
                await database.clear();
                if (!context.mounted) return;
                context.showSnackBar(message: 'Success Clear Database & Cache');
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ),
        ],
      ),
    );
  }
}
