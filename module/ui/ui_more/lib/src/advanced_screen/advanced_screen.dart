import 'package:dio_inspector/dio_inspector.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_screen_cubit.dart';
import 'advanced_screen_state.dart';

class AdvancedScreen extends StatelessWidget {
  final DioInspector inspector;
  final LogBox logBox;
  final DatabaseViewer viewer;
  final AppDatabase database;

  const AdvancedScreen({
    super.key,
    required this.inspector,
    required this.logBox,
    required this.viewer,
    required this.database,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (_) => AdvancedScreenCubit(
        initialState: const AdvancedScreenState(),
      ),
      child: AdvancedScreen(
        inspector: locator(),
        logBox: locator(),
        database: locator(),
        viewer: locator(),
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
            onTap: () => logBox.navigateToLogBox(),
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
                context.showSnackBar(message: 'Success Clear Database');
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ),
        ],
      ),
    );
  }
}
